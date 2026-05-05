//
//  CreateGroupView.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

internal import Auth
import Supabase
import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    var onCreate: (ChatGroup) -> Void

    let maxGroupNameLength = 50

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Group")
                .font(.title.bold())

            TextField("Group name", text: $groupName)
                .padding()
                .background(Color.surfaceContainerHigh)
                .cornerRadius(12)
                .onChange(of: groupName) { newValue in
                    if newValue.count > maxGroupNameLength {
                        groupName = String(newValue.prefix(maxGroupNameLength))
                    }
                }

            Button {
                Task {
                    await createGroup()
                }
            } label: {
                Text("Create")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryContainer)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .background(Color.background.ignoresSafeArea())
    }

    private func createGroup() async {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, trimmedName.count <= maxGroupNameLength else {
            print("Group name too long or empty")
            return
        }

        do {
            let session = try await SupabaseManager.shared.client.auth.session

            let payload = CreateGroupPayload(
                name: trimmedName,
                created_by: session.user.id
            )

            let group: ChatGroup = try await SupabaseManager.shared.client
                .from("chat_groups")
                .insert(payload)
                .select()
                .single()
                .execute()
                .value

            let memberPayload = AddMemberPayload(
                group_id: group.id,
                user_id: session.user.id
            )

            _ = try await SupabaseManager.shared.client
                .from("chat_group_members")
                .insert(memberPayload)
                .execute()

            await MainActor.run {
                onCreate(group)
                dismiss()
            }

        } catch {
            print("Create group failed:", error)
        }
    }
}
