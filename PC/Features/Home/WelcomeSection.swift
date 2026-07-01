//
//  WelcomeSection.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI

struct WelcomeSection: View {
    @ObservedObject var network: NetworkMonitor
    @ObservedObject var profileService: ProfileService
    @Binding var showJoinCommunitySheet: Bool
    @Binding var showProfileSheet: Bool

    @State private var animateTitle = false

    var body: some View {
        VStack(alignment: .leading, spacing: profileService.greetingName.isEmpty ? 20 : 12) {
            HStack {
                HStack(spacing: 6) {
                    OnlineIndicator(isConnected: network.isConnected)
                    Text(network.isConnected ? "SYSTEM ONLINE" : "OFFLINE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(network.isConnected ? .primary : .gray)
                        .tracking(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((network.isConnected ? Color.primary : Color.gray).opacity(0.12))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)

                Spacer()

                if !profileService.greetingName.isEmpty {
                    Button {
                        withAnimation(.easeInOut) { showProfileSheet = true }
                    } label: {
                        Group {
                            if let cachedImage = profileService.cachedProfileImage {
                                Image(uiImage: cachedImage).resizable().scaledToFill()
                            } else if let urlString = profileService.profileImageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in image.resizable().scaledToFill() } placeholder: { ProgressView() }
                            } else {
                                Image(systemName: "person.fill").resizable().scaledToFit().padding(8).foregroundColor(.white).frame(width: 36, height: 36).background(Color.primaryContainer)
                            }
                        }
                        .frame(width: 36, height: 36).background(Color.surfaceContainerHigh).clipShape(Circle())
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                if profileService.greetingName.isEmpty {
                    Text("Welcome to")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)
                        .opacity(animateTitle ? 1 : 0)
                        .offset(y: animateTitle ? 0 : 10)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("PROGRAMMING").modifier(Shimmer()).font(.system(size: 38, weight: .black)).foregroundColor(.primaryContainer)
                            .scaleEffect(animateTitle ? 1 : 0.9).opacity(animateTitle ? 1 : 0).offset(y: animateTitle ? 0 : 25)
                        Text("CLUB").modifier(Shimmer()).font(.system(size: 38, weight: .black)).foregroundColor(.primaryContainer)
                            .scaleEffect(animateTitle ? 1 : 0.9).opacity(animateTitle ? 1 : 0).offset(y: animateTitle ? 0 : 35)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hello,")
                            .font(.system(size: 24, weight: .medium)).foregroundColor(.onSurfaceVariant)
                            .opacity(animateTitle ? 1 : 0).offset(y: animateTitle ? 0 : 10)
                        Text(profileService.greetingName)
                            .font(.system(size: 38, weight: .black)).foregroundColor(.primaryContainer)
                            .opacity(animateTitle ? 1 : 0).offset(y: animateTitle ? 0 : 20)
                    }
                }
            }
            .onAppear { withAnimation(.easeOut(duration: 0.6)) { animateTitle = true } }

            if profileService.greetingName.isEmpty {
                Text("Your competitive programming workspace: editorials, problem sets, and insights to help you improve faster.")
                    .font(.system(size: 14)).foregroundColor(.onSurfaceVariant)

                Button {
                    if network.isConnected { showJoinCommunitySheet = true }
                } label: {
                    HStack {
                        Text("JOIN THE COMMUNITY")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(network.isConnected ? .black : .onSurfaceVariant)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(network.isConnected ? Color.white : Color.surfaceContainerHigh)
                    .cornerRadius(12)
                    .shadow(color: network.isConnected ? Color.white.opacity(0.15) : .clear, radius: 12, y: 4)
                }
                .disabled(!network.isConnected)
                .padding(.top, 6)
            }
        }
    }
}
