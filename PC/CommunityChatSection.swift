//
//  CommunityChatSection.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Supabase
import SwiftUI

struct CommunityChatSection: View {
    @State private var groups: [ChatGroup] = []
    @State private var selectedGroup: ChatGroup?
    @State private var showCreateGroup = false
    @State private var showFullScreenChat = false
    @State private var currentUserId: UUID?
    @State private var showGroupActions = false
    @State private var actionGroup: ChatGroup?
    @State private var showRenameGroup = false
    @State private var newGroupName = ""
    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmationText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Community Chat")
                    .font(.headline)
                    .foregroundColor(.onSurface)

                Spacer()

                if selectedGroup != nil {
                    Button {
                        showFullScreenChat = true
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.primaryContainer)
                            .padding(8)
                            .background(Color.surfaceContainerHigh)
                            .clipShape(Circle())
                    }
                }
            }

            if groups.isEmpty {
                Button {
                    showCreateGroup = true
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                        Text("Create a Group")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .foregroundColor(.primaryContainer)
                    .background(Color.surfaceContainerHigh)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.outlineVariant.opacity(0.15))
                    )
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(groups) { group in
                                Button {
                                    selectedGroup = group
                                } label: {
                                    Text(group.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedGroup?.id == group.id ? Color.primaryContainer : Color.surfaceContainerHigh)
                                        .foregroundColor(selectedGroup?.id == group.id ? .black : .onSurface)
                                        .cornerRadius(12)
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            triggerHaptic()
                                            actionGroup = group
                                            showGroupActions = true
                                        }
                                )
                                .confirmationDialog(
                                    "Group Options",
                                    isPresented: $showGroupActions
                                ) {
                                    Button("Rename") {
                                        newGroupName = actionGroup?.name ?? ""
                                        showRenameGroup = true
                                    }

                                    Button("Delete", role: .destructive) {
                                        deleteConfirmationText = ""
                                        showDeleteConfirmation = true
                                    }

                                    Button("Cancel", role: .cancel) {}
                                }
                                .alert("Delete \"\(actionGroup?.name ?? "")\"?", isPresented: $showDeleteConfirmation) {
                                    TextField("Type group name to confirm", text: $deleteConfirmationText)

                                    Button("Delete", role: .destructive) {
                                        guard deleteConfirmationText == actionGroup?.name else { return }
                                        Task { await deleteGroup() }
                                    }

                                    Button("Cancel", role: .cancel) {
                                        deleteConfirmationText = ""
                                    }
                                }
                            }

                            Button {
                                showCreateGroup = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.primaryContainer)
                                    .frame(width: 42, height: 42)
                                    .background(Color.surfaceContainerHigh)
                                    .cornerRadius(12)
                            }
                        }
                    }

                    if let selectedGroup {
                        ChatBoxView(group: selectedGroup, currentUserId: currentUserId)
                            .frame(height: 420)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateGroup) {
            CreateGroupView { newGroup in
                if !groups.contains(where: { $0.id == newGroup.id }) {
                    groups.append(newGroup)
                }
                selectedGroup = newGroup
            }
            .bottomSheetStyle()
        }
        .fullScreenCover(isPresented: $showFullScreenChat) {
            if let selectedGroup {
                FullScreenChatView(group: selectedGroup, currentUserId: currentUserId)
            }
        }
        .task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                currentUserId = session.user.id
            } catch {
                print("Failed to get current user:", error)
            }

            if groups.isEmpty {
                await loadGroups()
            }
        }
        .sheet(isPresented: $showRenameGroup) {
            if let groupToRename = selectedGroup {
                RenameGroupView(group: groupToRename) { newName in
                    if let index = groups.firstIndex(where: { $0.id == groupToRename.id }) {
                        let updatedGroup = ChatGroup(
                            id: groupToRename.id,
                            name: newName
                        )

                        groups[index] = updatedGroup
                        selectedGroup = updatedGroup
                    }
                }
                .bottomSheetStyle()
            }
        }
    }

    private func deleteGroup() async {
        guard let group = actionGroup else { return }

        do {
            _ = try await SupabaseManager.shared.client
                .from("chat_groups")
                .delete()
                .eq("id", value: group.id)
                .execute()

            await loadGroups()

            if selectedGroup?.id == group.id {
                selectedGroup = groups.first
            }

        } catch {
            print("Delete failed:", error)
        }
    }

    private func loadGroups() async {
        do {
            guard let uid = currentUserId else { return }

            let data: [ChatGroupMemberWithGroup] = try await SupabaseManager.shared.client
                .from("chat_group_members")
                .select("chat_groups(*)")
                .eq("user_id", value: uid)
                .execute()
                .value

            await MainActor.run {
                var seen = Set<UUID>()
                let uniqueGroups = data.map(\.chat_groups).filter { seen.insert($0.id).inserted }

                groups = uniqueGroups
                if selectedGroup == nil {
                    selectedGroup = groups.first
                }
            }
        } catch {
            print("Failed to load groups:", error)
        }
    }
}
