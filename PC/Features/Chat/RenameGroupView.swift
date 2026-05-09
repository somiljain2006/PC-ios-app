//
//  RenameGroupView.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Supabase
import SwiftUI

struct RenameGroupView: View {
    let group: ChatGroup
    var onRename: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var newGroupName: String = ""
    @State private var isLoading = false

    let maxGroupNameLength = 50

    var body: some View {
        VStack(spacing: 20) {
            Text("Rename Group")
                .font(.title.bold())

            TextField("New group name", text: $newGroupName)
                .padding()
                .background(Color.surfaceContainerHigh)
                .cornerRadius(12)
                .onChange(of: newGroupName) { newValue in
                    if newValue.count > maxGroupNameLength {
                        newGroupName = String(newValue.prefix(maxGroupNameLength))
                    }
                }

            Button {
                Task {
                    await renameGroup()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.primaryContainer)
            .foregroundColor(.black)
            .cornerRadius(12)
            .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)

            Spacer()
        }
        .padding()
        .background(Color.background.ignoresSafeArea())
        .onAppear {
            newGroupName = group.name
        }
    }

    private func renameGroup() async {
        let trimmedName = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, trimmedName.count <= maxGroupNameLength else {
            print("Group name too long or empty")
            return
        }

        isLoading = true

        do {
            let payload = RenameGroupPayload(name: trimmedName)

            try await SupabaseManager.shared.client
                .from("chat_groups")
                .update(payload)
                .eq("id", value: group.id)
                .execute()

            await MainActor.run {
                onRename(trimmedName)
                dismiss()
            }

        } catch {
            print("Rename failed:", error)
        }

        isLoading = false
    }
}
