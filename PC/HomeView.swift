//
//  HomeView.swift
//  PC
//
//  Created by somil jain on 12/04/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: String = "home"
    @StateObject private var network = NetworkMonitor()
    @State private var animateTitle = false
    @State private var glow = false
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case "about":
                    AboutView()
                case "events":
                    EventsView()
                case "editorial":
                    EditorialView()
                default:
                    homeContent
                }
            }

            VStack(spacing: 0) {
                Spacer()

                Rectangle()
                    .fill(Color.outlineVariant.opacity(0.3))
                    .frame(height: 1)

                HStack {
                    Button {
                        selectedTab = "home"
                    } label: {
                        NavItem(icon: "house.fill", title: "Home", active: selectedTab == "home")
                    }

                    Button {
                        selectedTab = "editorial"
                    } label: {
                        NavItem(icon: "doc.text", title: "Editorial", active: selectedTab == "editorial")
                    }

                    Button {
                        selectedTab = "events"
                    } label: {
                        NavItem(icon: "calendar", title: "Events", active: selectedTab == "events")
                    }

                    Button {
                        selectedTab = "about"
                    } label: {
                        NavItem(icon: "person.3", title: "About", active: selectedTab == "about")
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 34)
                .background(Color.surface)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var homeContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 6) {
                        OnlineIndicator(isConnected: network.isConnected)

                        Text(network.isConnected ? "SYSTEM ONLINE" : "OFFLINE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(network.isConnected ? .primary : .gray)
                            .tracking(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        (network.isConnected ? Color.primary : Color.gray)
                            .opacity(0.12)
                    )
                    .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome to")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.onSurfaceVariant)
                            .opacity(animateTitle ? 1 : 0)
                            .offset(y: animateTitle ? 0 : 10)

                        VStack(alignment: .leading, spacing: 0) {
                            Text("PROGRAMMING")
                                .modifier(Shimmer())
                                .font(.system(size: 38, weight: .black))
                                .foregroundColor(.primaryContainer)
                                .scaleEffect(animateTitle ? 1 : 0.9)
                                .opacity(animateTitle ? 1 : 0)
                                .offset(y: animateTitle ? 0 : 25)
                                .shadow(color: glow ? Color.primaryContainer.opacity(0.6) : .clear, radius: 12)

                            Text("CLUB")
                                .modifier(Shimmer())
                                .font(.system(size: 38, weight: .black))
                                .foregroundColor(.primaryContainer)
                                .scaleEffect(animateTitle ? 1 : 0.9)
                                .opacity(animateTitle ? 1 : 0)
                                .offset(y: animateTitle ? 0 : 35)
                                .shadow(color: glow ? Color.primaryContainer.opacity(0.6) : .clear, radius: 12)
                        }
                    }
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6)) { animateTitle = true
                        }
                    }

                    Text("""
                    Your competitive programming workspace: editorials, problem sets, and insights to help you improve faster.
                    """)
                    .font(.system(size: 14))
                    .foregroundColor(.onSurfaceVariant)

                    Button {
                        if network.isConnected {
                            handleJoinCommunity()
                        }
                    } label: {
                        HStack {
                            Text("JOIN THE COMMUNITY")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(network.isConnected ? .black : .onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            network.isConnected
                                ? Color.white
                                : Color.surfaceContainerHigh
                        )
                        .cornerRadius(12)
                        .shadow(
                            color: network.isConnected ? Color.white.opacity(0.15) : .clear,
                            radius: 12,
                            y: 4
                        )
                    }
                    .disabled(!network.isConnected)
                    .padding(.top, 6)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("CP Arena")
                        .font(.headline)
                        .foregroundColor(.onSurface)

                    HStack(spacing: 12) {
                        QuickCard(image: "cses", imageSize: 60) {
                            openURL("https://cses.fi/problemset/")
                        }

                        QuickCard(image: "cp31", imageSize: 80) {
                            openURL("https://www.tle-eliminators.com/cp-sheet")
                        }

                        QuickCard(
                            image: "striver",
                            title: "Striver's Sheet",
                            imageSize: 34
                        ) {
                            openURL("https://takeuforward.org/dsa/strivers-a2z-sheet-learn-dsa-a-to-z")
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 14) {
                        ModernFeatureCard(
                            title: "Coding",
                            desc: "Build strong foundations in algorithms and data structures.",
                            icon: "chevron.left.slash.chevron.right"
                        )

                        ModernFeatureCard(
                            title: "Competitive Programming",
                            desc: "Compete, improve speed, and master contest strategies.",
                            icon: "bolt.fill"
                        )

                        ModernFeatureCard(
                            title: "Problem Solving",
                            desc: "Break down complex problems into efficient solutions.",
                            icon: "brain.head.profile"
                        )
                    }
                }

                Spacer(minLength: 60)
            }
            .padding()
            .padding(.top, 10)
        }
    }

    private func handleJoinCommunity() {
        if let url = URL(string: "https://www.programmingclub.live/") {
            UIApplication.shared.open(url)
        }
    }

    private func openURL(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }
}

struct Shimmer: ViewModifier {
    @State private var move = false

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.3), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: move ? 200 : -200)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    move = true
                }
            }
    }
}

struct OnlineIndicator: View {
    var isConnected: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            if isConnected {
                Circle()
                    .fill(Color.green.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .scaleEffect(pulse ? 1.6 : 1)
                    .opacity(pulse ? 0 : 1)
            }

            Circle()
                .fill(isConnected ? Color.green : Color.gray)
                .frame(width: 6, height: 6)
        }
        .onAppear {
            guard isConnected else { return }
            withAnimation(
                .easeOut(duration: 1.2)
                    .repeatForever(autoreverses: false)
            ) {
                pulse = true
            }
        }
    }
}

struct QuickCard: View {
    var icon: String?
    var image: String?
    var title: String?
    var imageSize: CGFloat = 28
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    if let image {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                    } else if let icon {
                        Image(systemName: icon)
                            .font(.system(size: imageSize))
                            .foregroundColor(.primary)
                    }
                }

                if let title {
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 10)
            .background(Color.surfaceContainerLow)
            .cornerRadius(12)
        }
    }
}

struct ModernFeatureCard: View {
    var title: String
    var desc: String
    var icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.primaryContainer)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.onSurface)

                Text(desc)
                    .font(.system(size: 13))
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer()
        }
        .padding()
        .background(Color.surfaceContainerHigh)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.outlineVariant.opacity(0.15))
        )
    }
}

struct StatsBoardCard: View {
    var body: some View {
        VStack(spacing: 36) {
            HStack(spacing: 0) {
                StatItemView(number: "500+", label: "ACTIVE MEMBERS")
                    .frame(maxWidth: .infinity)

                StatItemView(number: "120+", label: "WEEKLY CONTESTS")
                    .frame(maxWidth: .infinity)
            }

            StatItemView(number: "10+", label: "EDITORIAL WRITTEN")
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(16)
    }
}

struct StatItemView: View {
    var number: String
    var label: String

    var body: some View {
        VStack(spacing: 8) {
            Text(number)
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(Color.onSurfaceVariant)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.onSurfaceVariant)
                .tracking(1.5)
        }
    }
}

struct StatCard: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title.bold())
                .foregroundColor(Color.onSurface)

            Text(subtitle.uppercased())
                .font(.caption2)
                .foregroundColor(Color.onSurfaceVariant)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.surfaceContainerLow)
        .cornerRadius(12)
    }
}

struct FeatureCard: View {
    var icon: String
    var title: String
    var desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .foregroundColor(Color.onSurface)
                    .fontWeight(.bold)

                Text(desc)
                    .foregroundColor(Color.onSurfaceVariant)
                    .font(.caption)
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(12)
    }
}

struct NavItem: View {
    var icon: String
    var title: String
    var active: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
            Text(title)
                .font(.caption2)
        }
        .foregroundColor(active ? Color.primary : Color.onSurfaceVariant.opacity(0.6))
        .frame(maxWidth: .infinity)
    }
}

struct SocialButton: View {
    var imageName: String?
    var systemName: String?
    var url: String

    var body: some View {
        if let validURL = URL(string: url) {
            Link(destination: validURL) {
                buttonLabel
            }
        }
    }

    private var buttonLabel: some View {
        ZStack {
            Circle()
                .fill(Color.surfaceContainerHigh)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.outlineVariant.opacity(0.2), lineWidth: 1)
                )

            if let systemName {
                Image(systemName: systemName)
                    .font(.system(size: 22))
                    .foregroundColor(Color.primary)
            } else if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageName == "Web" ? 32 : 26,
                           height: imageName == "Web" ? 32 : 26)
            }
        }
    }
}

#Preview {
    HomeView()
}
