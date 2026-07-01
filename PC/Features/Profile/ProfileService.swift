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
    @Published var cachedProfileImage: UIImage?

    private let avatarBucket = "avatars"
    private let avatarSignedURLExpiry = 60 * 60 * 24 * 7

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
            cachedProfileImage = loadCachedAvatar(for: session.user.id.uuidString)
            profileImageURL = await resolvedAvatarURL(from: profile.avatar_url)

        } catch {
            print("Failed to load profile:", error.localizedDescription)
            greetingName = ""
            profileImageURL = nil
            cachedProfileImage = nil
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

            saveCachedAvatar(imageData, for: userId)
            cachedProfileImage = UIImage(data: imageData)

            try await SupabaseManager.shared.client.storage
                .from(avatarBucket)
                .upload(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        cacheControl: "60",
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )

            try await SupabaseManager.shared.client
                .from("profiles")
                .update(["avatar_url": filePath])
                .eq("id", value: session.user.id)
                .execute()

            profileImageURL = await resolvedAvatarURL(from: filePath)
            print("Upload success:", filePath)

        } catch {
            print("Upload failed:", error)
        }
    }

    private func resolvedAvatarURL(from storedValue: String?) async -> String? {
        guard let storedValue = storedValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !storedValue.isEmpty
        else {
            return nil
        }

        guard let storagePath = avatarStoragePath(from: storedValue) else {
            return storedValue
        }

        let cacheNonce = String(Int(Date().timeIntervalSince1970))

        if let signedURL = try? await SupabaseManager.shared.client.storage
            .from(avatarBucket)
            .createSignedURL(
                path: storagePath,
                expiresIn: avatarSignedURLExpiry,
                cacheNonce: cacheNonce
            )
        {
            return signedURL.absoluteString
        }

        if let publicURL = try? SupabaseManager.shared.client.storage
            .from(avatarBucket)
            .getPublicURL(path: storagePath, cacheNonce: cacheNonce)
        {
            return publicURL.absoluteString
        }

        return storedValue.hasPrefix("http") ? storedValue : nil
    }

    private func avatarStoragePath(from storedValue: String) -> String? {
        if !storedValue.localizedCaseInsensitiveContains("://") {
            let bucketPrefix = "\(avatarBucket)/"
            if storedValue.hasPrefix(bucketPrefix) {
                return String(storedValue.dropFirst(bucketPrefix.count))
            }
            return storedValue
        }

        guard let components = URLComponents(string: storedValue) else { return nil }
        let pathSegments = components.path.split(separator: "/").map(String.init)

        guard let bucketIndex = pathSegments.lastIndex(of: avatarBucket),
              bucketIndex + 1 < pathSegments.count
        else {
            return nil
        }

        let storagePath = pathSegments[(bucketIndex + 1)...].joined(separator: "/")
        return storagePath.removingPercentEncoding ?? storagePath
    }

    private func loadCachedAvatar(for userId: String) -> UIImage? {
        guard let data = try? Data(contentsOf: cachedAvatarURL(for: userId)) else { return nil }
        return UIImage(data: data)
    }

    private func saveCachedAvatar(_ data: Data, for userId: String) {
        do {
            let fileURL = cachedAvatarURL(for: userId)
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to cache avatar:", error.localizedDescription)
        }
    }

    private func cachedAvatarURL(for userId: String) -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ProfileAvatars", isDirectory: true)
            .appendingPathComponent("\(userId).jpg")
    }
}
