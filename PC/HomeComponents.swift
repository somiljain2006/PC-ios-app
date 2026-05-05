//
//  HomeComponents.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import SwiftUI

struct DailyChallengeCard: View {
    let problem: UnifiedProblem
    let onTogglePin: (UnifiedProblem) -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(problem.name)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.onSurface)
                        .lineLimit(2)

                    Text("\(problem.platform) • \(problem.identifier)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)

                    FlowLayout(data: problem.tags) { tag in
                        Text(tag)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.primaryContainer)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.primaryContainer.opacity(0.15))
                            .cornerRadius(6)
                    }
                    .padding(.top, 4)
                }

                Spacer()

                Image(problem.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }

            Spacer(minLength: 0)

            Button {
                if let url = problem.url {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Solve Problem")
                    Image(systemName: "arrow.up.right")
                    Spacer()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(.vertical, 12)
                .background(Color.primaryContainer)
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primaryContainer.opacity(0.3))
        )
        .scaleEffect(isPressed ? 0.96 : 1)
        .onLongPressGesture(
            minimumDuration: 0.6,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPressed = pressing
                }
            },
            perform: {
                triggerHaptic()
                onTogglePin(problem)
            }
        )
    }
}

struct FlowLayout<Item: Hashable, Content: View>: View {
    let data: [Item]
    let spacing: CGFloat
    let content: (Item) -> Content

    init(
        data: [Item],
        spacing: CGFloat = 6,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(data, id: \.self) { item in
                content(item)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geo.size.width {
                            width = 0
                            height -= dimension.height + spacing
                        }
                        let result = width
                        if item == data.last {
                            width = 0
                        } else {
                            width -= dimension.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == data.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geo.size.height
            }
            return Color.clear
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

struct CustomBottomNavBar: View {
    @Binding var selectedTab: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Rectangle()
                .fill(Color.outlineVariant.opacity(0.3))
                .frame(height: 1)

            HStack {
                Button { selectedTab = "home" } label: { NavItem(icon: "house.fill", title: "Home", active: selectedTab == "home") }
                Button { selectedTab = "editorial" } label: { NavItem(icon: "doc.text", title: "Editorial", active: selectedTab == "editorial") }
                Button { selectedTab = "events" } label: { NavItem(icon: "calendar", title: "Events", active: selectedTab == "events") }
                Button { selectedTab = "about" } label: { NavItem(icon: "person.3", title: "About", active: selectedTab == "about") }
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

struct CPArenaSection: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CP Arena")
                .font(.headline)
                .foregroundColor(.onSurface)

            HStack(spacing: 12) {
                QuickCard(image: "cses", imageSize: 60) {
                    if let url = URL(string: "https://cses.fi/problemset/") { openURL(url) }
                }

                QuickCard(image: "cp31", imageSize: 80) {
                    if let url = URL(string: "https://www.tle-eliminators.com/cp-sheet") { openURL(url) }
                }

                QuickCard(image: "striver", title: "Striver's Sheet", imageSize: 34) {
                    if let url = URL(string: "https://takeuforward.org/dsa/strivers-a2z-sheet-learn-dsa-a-to-z") { openURL(url) }
                }
            }
        }
    }
}

struct FeaturesSection: View {
    var body: some View {
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
    }
}
