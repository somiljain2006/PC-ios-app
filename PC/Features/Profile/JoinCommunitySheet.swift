//
//  JoinCommunitySheet.swift
//  PC
//
//  Created by somil jain on 01/05/26.
//

import SwiftUI

struct JoinCommunitySheet: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = JoinCommunityViewModel()

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(
                                viewModel.isForgotPasswordMode
                                    ? "Reset Password"
                                    : (viewModel.isLoginMode ? "Login" : "Join the Community")
                            )
                            .font(.system(size: 28, weight: .bold))
                        }
                    }

                    if !viewModel.isForgotPasswordMode {
                        Button {
                            showImagePicker = true
                        } label: {
                            VStack(spacing: 16) {
                                ZStack {
                                    if let selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image(systemName: "person.crop.circle.fill.badge.plus")
                                            .font(.system(size: 34))
                                            .foregroundColor(.primaryContainer)
                                    }
                                }
                                .frame(width: 92, height: 92)
                                .background(Color.surfaceContainerHigh)
                                .clipShape(Circle())

                                Text("Add Profile Photo")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primaryContainer)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Group {
                        if viewModel.isForgotPasswordMode {
                            TextField("Username or Email", text: $viewModel.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            if viewModel.isLoginMode {
                                TextField("Username or Email", text: $viewModel.username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                TextField("Username", text: $viewModel.username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }

                            if !viewModel.isLoginMode {
                                TextField("Email", text: $viewModel.email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                            }

                            SecureField("Password", text: $viewModel.password)
                        }
                    }
                    .padding()
                    .background(Color.surfaceContainerHigh)
                    .cornerRadius(14)
                    .foregroundColor(.onSurface)

                    if viewModel.isLoginMode, !viewModel.isForgotPasswordMode {
                        HStack {
                            Spacer()

                            Button {
                                withAnimation {
                                    viewModel.isForgotPasswordMode = true
                                    viewModel.errorMessage = nil
                                }
                            } label: {
                                Text("Forgot Password?")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primaryContainer)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.top, 6)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 4)
                    }

                    Button {
                        Task {
                            if viewModel.isForgotPasswordMode {
                                let success = await viewModel.resetPassword()
                                if success {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { dismiss() }
                                }
                            } else if viewModel.isLoginMode {
                                let success = await viewModel.login()
                                if success { dismiss() }
                            } else {
                                let success = await viewModel.signUp()
                                if success { dismiss() }
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text(viewModel.isForgotPasswordMode ? "Send Reset Link" : (viewModel.isLoginMode ? "Login" : "Create Account"))
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            viewModel.isFormInvalid
                                ? Color.white.opacity(0.5)
                                : Color.white
                        )
                        .foregroundColor(.black)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isFormInvalid)

                    Button {
                        withAnimation {
                            if viewModel.isForgotPasswordMode {
                                viewModel.isForgotPasswordMode = false
                            } else {
                                viewModel.isLoginMode.toggle()
                            }

                            viewModel.errorMessage = nil
                            viewModel.username = ""
                            viewModel.email = ""
                            viewModel.password = ""
                        }
                    } label: {
                        HStack {
                            Text(viewModel.isForgotPasswordMode
                                ? "Back to Login"
                                : (viewModel.isLoginMode
                                    ? "Don't have an account?"
                                    : "Already have an account?"))
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.surfaceContainerHigh)
                        .foregroundColor(.primaryContainer)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 4)
                }
                .padding()
                .padding(.top, 32)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}
