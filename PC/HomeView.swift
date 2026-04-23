//
//  HomeView.swift
//  PC
//
//  Created by somil jain on 12/04/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: String = "home"
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
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 8, height: 8)

                        Text("STATUS: COMPILING EXCELLENCE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.primary)
                            .tracking(2)
                    }
                    .padding(8)
                    .background(Color.primary.opacity(0.1))
                    .cornerRadius(20)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hi There!")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color.onSurface)

                        Text("We Are")
                            .font(.system(size: 42, weight: .light))
                            .italic()
                            .foregroundColor(Color.onSurfaceVariant)

                        VStack(alignment: .leading, spacing: 0) {
                            Text("Programming")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(Color.primary)

                            Text("Club")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(Color.primary)
                        }

                        Text("""
                        The apex community for algorithm
                        enthusiasts, software architects, and
                        competitive problem solvers.
                        """)
                        .font(.system(size: 14))
                        .foregroundColor(Color.onSurfaceVariant)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                        Button(
                            action: {},
                            label: {
                                Text("Join the Community")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.primary, Color.primaryContainer],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .foregroundColor(Color.onPrimaryContainer)
                                    .cornerRadius(10)
                            }
                        )
                        .padding(.top, 8)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center, spacing: 12) {
                            Text("What We Do")
                                .font(.title2.bold())
                                .foregroundColor(Color.onSurface)

                            Rectangle()
                                .fill(Color.outlineVariant.opacity(0.3))
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                        }

                        FeatureCard(
                            icon: "bolt.fill",
                            title: "Competitive Programming",
                            desc: "Sharpen your problem-solving skills through contests, practice sessions, and different coding challenges."
                        )

                        FeatureCard(
                            icon: "point.3.connected.trianglepath.dotted",
                            title: "DSA Mastery",
                            desc: "Deep dives into complex data structures and optimal algorithm design."
                        )
                    }

                    ZStack(alignment: .bottomLeading) {
                        Image("code")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                            .opacity(0.4)

                        VStack(alignment: .leading) {
                            Text("#CODE_EVERYDAY")
                                .font(.caption)
                                .foregroundColor(Color.primary)

                            Text("EXECUTE DREAMS.")
                                .font(.title.bold())
                                .foregroundColor(Color.onSurface)
                        }
                        .padding()
                    }
                    .cornerRadius(12)

                    StatsBoardCard()

                    Spacer(minLength: 50)

                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            SocialButton(imageName: "Linkedin", url: "https://www.linkedin.com/company/programming-club-akgec/mycompany/")
                            SocialButton(imageName: "Insta", url: "https://www.instagram.com/programmingclub.akgec/")
                            SocialButton(imageName: "Web", url: "https://www.programmingclub.live/")
                        }

                        Text("Connect with us on social media")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.onSurfaceVariant.opacity(0.7))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .padding(.top, 20)
                .padding()

                Spacer()
            }
        }
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
