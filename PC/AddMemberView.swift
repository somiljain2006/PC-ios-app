//
//  AddMemberView.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Supabase
import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    let groupId: UUID

    @State private var username = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Member")
                .font(.title.bold())

            TextField("Username", text: $username)
                .padding()
                .background(Color.surfaceContainerHigh)
                .cornerRadius(12)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button {
                Task {
                    await addMember()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.primaryContainer)
            .foregroundColor(.black)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .background(Color.background.ignoresSafeArea())
    }

    private func addMember() async {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter a username"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            struct UserRow: Decodable {
                let id: UUID
            }

            let user: UserRow = try await SupabaseManager.shared.client
                .from("profiles")
                .select("id")
                .eq("username", value: username.lowercased())
                .single()
                .execute()
                .value

            let payload = AddMemberPayload(
                group_id: groupId,
                user_id: user.id
            )

            _ = try await SupabaseManager.shared.client
                .from("chat_group_members")
                .insert(payload)
                .execute()

            dismiss()

        } catch {
            errorMessage = "User not found or already in group"
        }

        isLoading = false
    }
}
