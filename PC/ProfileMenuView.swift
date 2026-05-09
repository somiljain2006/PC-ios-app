//
//  ProfileMenuView.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import SwiftUI
import UIKit

struct ProfileMenuView: View {
    @ObservedObject var profileService: ProfileService
    let onClose: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showLogoutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var deleteText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .padding(10)
                            .background(Color.surfaceContainerHigh)
                            .clipShape(Circle())
                    }
                }

                VStack(spacing: 10) {
                    if let urlString = profileService.profileImageURL,
                       let url = URL(string: urlString)
                    {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .foregroundColor(.white)
                            .frame(width: 90, height: 90)
                            .background(Color.primaryContainer)
                    }
                }
                .frame(width: 90, height: 90)
                .clipShape(Circle())

                Button("Edit Profile Picture") {
                    showImagePicker = true
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primaryContainer)

                Divider()

                NavigationLink {
                    ProgressViewScreen()
                } label: {
                    row(icon: "chart.bar.fill", title: "Progressboard")
                }

                Button {
                    showLogoutConfirm = true
                } label: {
                    row(icon: "arrow.backward.circle.fill", title: "Logout")
                }
                .alert("Logout?", isPresented: $showLogoutConfirm) {
                    Button("Logout", role: .destructive) {
                        Task {
                            await profileService.logout()
                            dismiss()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to logout?")
                }

                Button(role: .destructive) {
                    deleteText = ""
                    showDeleteConfirm = true
                } label: {
                    row(icon: "trash.fill", title: "Delete Account", isDestructive: true)
                }
                .alert("Delete Account", isPresented: $showDeleteConfirm) {
                    TextField("Type DELETE to confirm", text: $deleteText)

                    Button("Delete", role: .destructive) {
                        guard deleteText == "DELETE" else { return }
                        Task {
                            await profileService.deleteAccount()
                            dismiss()
                        }
                    }

                    Button("Cancel", role: .cancel) {
                        deleteText = ""
                    }
                } message: {
                    Text("This action is permanent and cannot be undone.")
                }

                Spacer()
            }
            .padding()
            .background(Color.background.ignoresSafeArea())
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { newImage in
                guard let image = newImage else { return }
                Task {
                    await profileService.uploadAvatar(image)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func row(icon: String, title: String, isDestructive: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .semibold))

            Spacer()
        }
        .foregroundColor(isDestructive ? .red : .onSurface)
        .padding()
        .background(Color.surfaceContainerHigh)
        .cornerRadius(12)
    }
}
