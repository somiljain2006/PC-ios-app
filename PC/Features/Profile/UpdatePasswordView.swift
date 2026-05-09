//
//  UpdatePasswordView.swift
//  PC
//
//  Created by somil jain on 02/05/26.
//

internal import Auth
import Supabase
import SwiftUI

struct UpdatePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Text("Enter your new password below.")
                    .foregroundColor(.gray)

                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if let successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                }

                Button {
                    Task { await updatePassword() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Update Password")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(newPassword.count < 6 ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(newPassword.count < 6 || isLoading)
                .padding(.horizontal)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func updatePassword() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let attributes = UserAttributes(password: newPassword)
            try await SupabaseManager.shared.client.auth.update(user: attributes)

            successMessage = "Password updated successfully!"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            errorMessage = "Failed to update password: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
