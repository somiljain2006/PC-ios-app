//
//  ChatBoxView.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Supabase
import SwiftUI

struct ChatBoxView: View {
    let group: ChatGroup
    let currentUserId: UUID?

    @StateObject private var chatService = ChatService()

    @State private var message = ""
    @State private var showAddMember = false
    @State private var isNearBottom = true

    let maxMessageLength = 1000

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()
                .background(Color.outlineVariant.opacity(0.25))

            messagesView

            inputBar
        }
        .padding(16)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(18)
        .sheet(isPresented: $showAddMember) {
            AddMemberView(groupId: group.id)
                .bottomSheetStyle()
        }
        .task(id: group.id) {
            await chatService.loadMessages(for: group, currentUserId: currentUserId)
        }
        .onDisappear {
            Task { await chatService.unsubscribe() }
        }
    }
}

private extension ChatBoxView {
    var header: some View {
        HStack {
            Text(group.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.onSurface)

            Spacer()

            Button {
                showAddMember = true
            } label: {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.primaryContainer)
                    .padding(8)
                    .background(Color.surfaceContainerLow)
                    .clipShape(Circle())
            }
        }
        .padding(.bottom, 12)
    }

    var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).maxY) { value in
                            let screenHeight = UIScreen.main.bounds.height
                            isNearBottom = value < screenHeight + 100
                        }
                }
                .frame(height: 0)

                VStack(alignment: .leading, spacing: 12) {
                    if chatService.messages.isEmpty,
                       chatService.loadingGroupId == group.id
                    {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 140)
                    } else if chatService.messages.isEmpty {
                        Text("No messages yet. Start the conversation.")
                            .foregroundColor(.onSurfaceVariant)
                            .frame(maxWidth: .infinity, minHeight: 140)
                    } else {
                        ForEach(chatService.messages) { msg in
                            messageBubble(msg)
                        }
                    }

                    Color.clear.frame(height: 1).id("BOTTOM")
                }
                .padding(.vertical, 12)
            }
            .onChange(of: chatService.messages.count) { _ in
                guard isNearBottom else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            }
            .onAppear {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }
        }
    }

    func messageBubble(_ msg: ChatMessage) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(msg.sender_id == currentUserId
                    ? "You"
                    : (msg.profiles?.username ?? String(msg.sender_id.uuidString.prefix(6))))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primaryContainer)

                Text(msg.message)
                    .foregroundColor(.onSurface)
                    .padding(12)
                    .background(Color.surfaceContainerLow)
                    .cornerRadius(12)
            }
            Spacer()
        }
    }

    var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Message...", text: $message)
                .padding(12)
                .background(Color.surfaceContainerLow)
                .cornerRadius(12)
                .foregroundColor(.onSurface)
                .disabled(chatService.isSending)
                .onChange(of: message) { newValue in
                    if newValue.count > maxMessageLength {
                        message = String(newValue.prefix(maxMessageLength))
                    }
                }

            Button {
                sendMessage()
            } label: {
                if chatService.isSending {
                    ProgressView()
                        .padding(12)
                        .background(Color.primaryContainer)
                        .cornerRadius(12)
                } else {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.primaryContainer)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.top, 8)
    }

    func sendMessage() {
        let msgToSend = message.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !chatService.isSending,
              !msgToSend.isEmpty,
              msgToSend.count <= maxMessageLength else { return }

        let temp = msgToSend
        message = ""

        Task {
            do {
                try await chatService.sendMessage(text: temp, group: group)
            } catch {
                print("Send failed:", error)
                message = temp
            }
        }
    }
}
