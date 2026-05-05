//
//  ChatService.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
final class ChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isSending = false
    @Published var loadingGroupId: UUID?

    private var channel: RealtimeChannelV2?

    func loadMessages(for group: ChatGroup, currentUserId: UUID?) async {
        if let cached = ChatCache.shared.messages[group.id] {
            messages = cached
        } else {
            messages = []
            loadingGroupId = group.id
        }

        do {
            let data: [ChatMessage] = try await SupabaseManager.shared.client
                .from("chat_messages")
                .select("*, profiles!chat_messages_sender_id_fkey(username)")
                .eq("group_id", value: group.id)
                .order("created_at", ascending: true)
                .execute()
                .value

            if !Task.isCancelled {
                messages = data
                ChatCache.shared.messages[group.id] = data
                if loadingGroupId == group.id { loadingGroupId = nil }
            }
        } catch {
            if !Task.isCancelled, loadingGroupId == group.id {
                loadingGroupId = nil
            }
        }

        await setupRealtime(for: group, currentUserId: currentUserId)
    }

    private func setupRealtime(for group: ChatGroup, currentUserId: UUID?) async {
        channel = SupabaseManager.shared.client.channel("room_\(group.id)")
        guard let channel else { return }

        let insertions = await channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "chat_messages",
            filter: .eq("group_id", value: group.id.uuidString)
        )

        do {
            try await channel.subscribeWithError()
        } catch {
            print("Failed to subscribe to channel:", error)
        }

        for await insert in insertions {
            do {
                var newMessage = try insert.record.decode(as: ChatMessage.self)

                if let knownMsg = messages.first(where: { $0.sender_id == newMessage.sender_id && $0.profiles != nil }) {
                    newMessage.profiles = knownMsg.profiles
                } else if newMessage.sender_id != currentUserId {
                    if let profile: ProfileRow = try? await SupabaseManager.shared.client
                        .from("profiles")
                        .select("username")
                        .eq("id", value: newMessage.sender_id)
                        .single()
                        .execute()
                        .value
                    {
                        newMessage.profiles = profile
                    }
                }

                if !messages.contains(where: { $0.id == newMessage.id }) {
                    messages.append(newMessage)
                    ChatCache.shared.messages[group.id] = messages
                }
            } catch {
                print("Failed to decode realtime message:", error)
            }
        }
    }

    func sendMessage(text: String, group: ChatGroup) async throws {
        isSending = true
        defer { isSending = false }

        let session = try await SupabaseManager.shared.client.auth.session

        let payload = SendMessagePayload(
            group_id: group.id,
            sender_id: session.user.id,
            message: text
        )

        var newMsg: ChatMessage?
        var lastError: Error?

        for _ in 0 ..< 3 {
            do {
                newMsg = try await SupabaseManager.shared.client
                    .from("chat_messages")
                    .insert(payload)
                    .select("*, profiles!chat_messages_sender_id_fkey(username)")
                    .single()
                    .execute()
                    .value
                break
            } catch {
                let nsError = error as NSError
                if nsError.code == NSURLErrorNetworkConnectionLost || nsError.code == -1005 {
                    lastError = error
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    continue
                } else {
                    throw error
                }
            }
        }

        guard let finalMsg = newMsg else {
            throw lastError ?? URLError(.unknown)
        }

        if group.id == payload.group_id {
            messages.append(finalMsg)
            ChatCache.shared.messages[group.id] = messages
        }
    }

    func unsubscribe() async {
        await channel?.unsubscribe()
    }
}
