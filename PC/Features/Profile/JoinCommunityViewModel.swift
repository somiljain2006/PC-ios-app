//
//  JoinCommunityViewModel.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

internal import Auth
internal import PostgREST
import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
final class JoinCommunityViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var isLoginMode = false
    @Published var isForgotPasswordMode = false

    func resetPassword() async -> Bool {
        errorMessage = nil
        let cleanInput = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanInput.isEmpty else {
            errorMessage = "Enter your email or username first."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            var emailToUse = cleanInput

            if !AuthValidator.isValidEmail(cleanInput) {
                let result: [ProfileLookup] = try await SupabaseManager.shared.client
                    .from("profiles")
                    .select("email")
                    .eq("username", value: cleanInput)
                    .limit(1)
                    .execute()
                    .value

                guard let fetchedEmail = result.first?.email else {
                    errorMessage = "Username not found."
                    return false
                }
                emailToUse = fetchedEmail
            }

            try await SupabaseManager.shared.client.auth.resetPasswordForEmail(
                emailToUse,
                redirectTo: URL(string: "pcapp://auth?type=recovery")
            )

            errorMessage = "Password reset link sent to your email."
            return true

        } catch {
            errorMessage = "Failed to send reset email."
            return false
        }
    }

    func signUp() async -> Bool {
        errorMessage = nil

        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = AuthValidator.validateInputs(username: cleanUsername, email: cleanEmail, password: password) {
            errorMessage = error
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if try await isUsernameTaken(cleanUsername) {
                errorMessage = "Username is already taken. Please choose another."
                return false
            }

            let response = try await SupabaseManager.shared.client.auth.signUp(
                email: cleanEmail,
                password: password
            )

            let user = response.user

            try await SupabaseManager.shared.client
                .from("profiles")
                .insert([
                    "id": user.id.uuidString,
                    "username": cleanUsername,
                    "email": cleanEmail,
                ])
                .execute()

            return true

        } catch let error as AuthError {
            handleAuthError(error)
            return false
        } catch {
            errorMessage = "Unexpected error occurred."
            return false
        }
    }

    func login() async -> Bool {
        errorMessage = nil

        let cleanInput = username.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanInput.isEmpty || password.isEmpty {
            errorMessage = "Please enter username/email and password."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            var emailToUse = cleanInput

            if !AuthValidator.isValidEmail(cleanInput) {
                let result: [ProfileLookup] = try await SupabaseManager.shared.client
                    .from("profiles")
                    .select("email")
                    .eq("username", value: cleanInput)
                    .limit(1)
                    .execute()
                    .value

                guard let fetchedEmail = result.first?.email else {
                    errorMessage = "Username not found."
                    return false
                }
                emailToUse = fetchedEmail
            }

            try await SupabaseManager.shared.client.auth.signIn(
                email: emailToUse,
                password: password
            )

            return true

        } catch let error as AuthError {
            handleLoginError(error)
            return false
        } catch {
            errorMessage = "Login failed. Please try again."
            return false
        }
    }

    var isFormInvalid: Bool {
        if isForgotPasswordMode {
            isLoading || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else if isLoginMode {
            isLoading ||
                username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                password.isEmpty
        } else {
            isLoading ||
                username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                password.isEmpty
        }
    }

    private func isUsernameTaken(_ username: String) async throws -> Bool {
        let existing: [UsernameCheck] = try await SupabaseManager.shared.client
            .from("profiles")
            .select("id")
            .eq("username", value: username)
            .execute()
            .value
        return !existing.isEmpty
    }

    private func handleAuthError(_ error: AuthError) {
        let message = String(describing: error).lowercased()
        if message.contains("user already registered") {
            errorMessage = "An account with this email already exists."
        } else if message.contains("invalid email") {
            errorMessage = "Invalid email address."
        } else if message.contains("password") {
            errorMessage = "Password is too weak."
        } else {
            errorMessage = "Signup failed. Please try again."
        }
    }

    private func handleLoginError(_ error: AuthError) {
        let message = String(describing: error).lowercased()
        if message.contains("invalid login credentials") {
            errorMessage = "Incorrect email or password."
        } else if message.contains("email not confirmed") {
            errorMessage = "Please verify your email first."
        } else {
            errorMessage = "Login failed. Please try again."
        }
    }
}
