//
//  ProfileService.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
final class ProfileService: ObservableObject {
    @Published var greetingName: String = ""
    @Published var profileImageURL: String?

    func loadProfile() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session

            let profile: ProfileRow = try await SupabaseManager.shared.client
                .from("profiles")
                .select("username, avatar_url")
                .eq("id", value: session.user.id)
                .single()
                .execute()
                .value

            greetingName = profile.username.trimmingCharacters(in: .whitespacesAndNewlines)
            profileImageURL = profile.avatar_url

        } catch {
            print("Failed to load profile:", error.localizedDescription)
            greetingName = ""
            profileImageURL = nil
        }
    }

    func logout() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            greetingName = ""
            profileImageURL = nil
        } catch {
            print("Logout failed:", error)
        }
    }

    func deleteAccount() async {
        do {
            try await SupabaseManager.shared.client.rpc("delete_user").execute()
            try await SupabaseManager.shared.client.auth.signOut()

            greetingName = ""
            profileImageURL = nil
            print("Account successfully deleted.")

        } catch {
            print("Failed to delete account:", error)
        }
    }

    func uploadAvatar(_ image: UIImage) async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let userId = session.user.id.uuidString

            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

            let filePath = "\(userId)/avatar.jpg"

            try await SupabaseManager.shared.client.storage
                .from("avatars")
                .upload(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )

            let publicURL = try SupabaseManager.shared.client.storage
                .from("avatars")
                .getPublicURL(path: filePath)

            let cacheBustedURL = publicURL.absoluteString + "?t=\(Int(Date().timeIntervalSince1970))"

            try await SupabaseManager.shared.client
                .from("profiles")
                .update(["avatar_url": cacheBustedURL])
                .eq("id", value: session.user.id)
                .execute()

            print("Upload success:", cacheBustedURL)
            profileImageURL = cacheBustedURL

        } catch {
            print("Upload failed:", error)
        }
    }
}
