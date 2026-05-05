//
//  HomeView.swift
//  PC
//
//  Created by somil jain on 12/04/26.
//

internal import Auth
import Supabase
import SwiftUI
import UIKit

struct HomeView: View {
    @State private var selectedTab: String = "home"
    @StateObject private var network = NetworkMonitor()
    @StateObject private var profileService = ProfileService()
    @State private var showJoinCommunitySheet = false
    @State private var challengeSlides: [UnifiedProblem] = []
    @State private var loopedSlides: [UnifiedProblem] = []
    @State private var isLoadingChallenge = false
    @State private var selectedSlideIndex: Int = 1
    @State private var showProfileSheet = false
    @GestureState private var dragOffset: CGFloat = 0

    private var dailyChallengeTitle: String {
        guard loopedSlides.indices.contains(selectedSlideIndex) else { return "Daily Challenges" }
        let slide = loopedSlides[selectedSlideIndex]
        return slide.platform.starts(with: "Daily Pick") ? "Daily Challenge" : "Daily \(slide.platform) Challenge"
    }

    private var realIndex: Int {
        let count = challengeSlides.count
        guard count > 0 else { return 0 }
        if selectedSlideIndex == 0 { return count - 1 }
        if selectedSlideIndex == loopedSlides.count - 1 { return 0 }
        return selectedSlideIndex - 1
    }

    private var isPinnedCardSelected: Bool {
        guard PinnedChallengeManager.load() != nil else { return false }
        return realIndex == 0
    }

    var body: some View {
        ZStack {
            ZStack {
                Color.background.ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case "about": AboutView()
                    case "events": EventsView()
                    case "editorial": EditorialView()
                    default: homeContent
                    }
                }

                CustomBottomNavBar(selectedTab: $selectedTab)
            }
            .sheet(
                isPresented: $showJoinCommunitySheet,
                onDismiss: { Task { await profileService.loadProfile() } },
                content: { JoinCommunitySheet().bottomSheetStyle() }
            )
            .task {
                if challengeSlides.isEmpty { await loadAllChallenges() }
                await profileService.loadProfile()
            }

            if showProfileSheet {
                ProfileSheetOverlay(
                    profileService: profileService,
                    showProfileSheet: $showProfileSheet
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showProfileSheet)
    }

    private var homeContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: profileService.greetingName.isEmpty ? 28 : 16) {
                WelcomeSection(
                    network: network,
                    profileService: profileService,
                    showJoinCommunitySheet: $showJoinCommunitySheet,
                    showProfileSheet: $showProfileSheet
                )

                dailyChallengeSection

                CPArenaSection()

                if !profileService.greetingName.isEmpty {
                    CommunityChatSection()
                }

                if profileService.greetingName.isEmpty {
                    FeaturesSection()
                }

                Spacer(minLength: 60)
            }
            .padding()
            .padding(.top, 10)
        }
    }

    private var dailyChallengeSection: some View {
        VStack(alignment: .leading, spacing: profileService.greetingName.isEmpty ? 12 : 8) {
            HStack {
                Text(dailyChallengeTitle).font(.headline).foregroundColor(.onSurface).animation(.easeInOut, value: selectedSlideIndex)
                Spacer()
                if isLoadingChallenge {
                    ProgressView().scaleEffect(0.8)
                } else {
                    if isPinnedCardSelected {
                        Button {
                            PinnedChallengeManager.clear()
                            Task { await loadAllChallenges() }
                        } label: { Image(systemName: "pin.slash").foregroundColor(.primaryContainer) }
                    }
                    Button {
                        Task { await loadAllChallenges() }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 14, weight: .bold)).foregroundColor(.primaryContainer).padding(8).background(Color.surfaceContainerHigh).clipShape(Circle())
                    }
                }
            }

            if !loopedSlides.isEmpty {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        let spacing: CGFloat = 16
                        let leadingPadding: CGFloat = 16
                        let peekAmount: CGFloat = 40
                        let cardWidth = geo.size.width - leadingPadding - spacing - peekAmount

                        HStack(spacing: spacing) {
                            ForEach(Array(loopedSlides.enumerated()), id: \.element.id) { _, problem in
                                DailyChallengeCard(
                                    problem: problem,
                                    onTogglePin: { selected in
                                        if let pinned = PinnedChallengeManager.load(),
                                           pinned.identifier == selected.identifier
                                        {
                                            PinnedChallengeManager.clear()
                                        } else { PinnedChallengeManager.save(selected) }
                                        Task { await loadAllChallenges() }
                                    }
                                ).frame(width: cardWidth)
                            }
                        }
                        .padding(.leading, leadingPadding)
                        .offset(x: -(CGFloat(selectedSlideIndex) * (cardWidth + spacing)))
                        .offset(x: dragOffset)
                        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: dragOffset)
                        .gesture(
                            DragGesture(minimumDistance: 15)
                                .updating($dragOffset) { value, state, _ in state = value.translation.width }
                                .onEnded { value in
                                    let swipeDistance = value.predictedEndTranslation.width
                                    var newIndex = selectedSlideIndex
                                    if swipeDistance < -cardWidth / 3 {
                                        newIndex = min(loopedSlides.count - 1, selectedSlideIndex + 1)
                                    } else if swipeDistance > cardWidth / 3 { newIndex = max(0, selectedSlideIndex - 1) }
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) { selectedSlideIndex = newIndex }
                                }
                        )
                    }
                    .frame(height: 240)
                    .onChange(of: selectedSlideIndex) { newValue in
                        let count = loopedSlides.count
                        guard count > 2 else { return }
                        if newValue == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                selectedSlideIndex = count - 2
                            }
                        } else if newValue == count - 1 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { selectedSlideIndex = 1 } }
                    }
                    .padding(.horizontal, -16).clipped().padding(.top, 16).padding(.bottom, 4)
                }
            } else if !isLoadingChallenge {
                Text("Connect to the internet to get today's challenge.").font(.caption).foregroundColor(.onSurfaceVariant).padding(.vertical, 20)
            } else {
                GeometryReader { geo in
                    let spacing: CGFloat = 16
                    let leadingPadding: CGFloat = 16
                    let peekAmount: CGFloat = 40
                    let cardWidth = geo.size.width - leadingPadding - spacing - peekAmount

                    HStack(spacing: spacing) {
                        DailyChallengeSkeletonCard().frame(width: cardWidth)
                        DailyChallengeSkeletonCard().frame(width: cardWidth)
                    }.padding(.leading, leadingPadding)
                }.frame(height: 240).padding(.horizontal, -16)
            }
        }
    }

    private func loadAllChallenges() async {
        isLoadingChallenge = true
        defer { isLoadingChallenge = false }

        let slides = await ProblemService.shared.loadAllChallenges()
        var ghosts = slides
        if let first = slides.first, let last = slides.last {
            ghosts.insert(last.copy(), at: 0)
            ghosts.append(first.copy())
        }

        withAnimation {
            challengeSlides = slides
            loopedSlides = ghosts
            selectedSlideIndex = 1
        }
    }
}

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
                            if let urlString = profileService.profileImageURL, let url = URL(string: urlString) {
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

struct ProfileSheetOverlay: View {
    @ObservedObject var profileService: ProfileService
    @Binding var showProfileSheet: Bool

    @GestureState private var profileDragOffset: CGFloat = 0
    @State private var profileOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showProfileSheet = false } }

            HStack {
                Spacer()
                let width: CGFloat = 300
                ProfileMenuView(
                    profileService: profileService,
                    onClose: {
                        withAnimation {
                            showProfileSheet = false
                            profileOffset = 0
                        }
                    }
                )
                .frame(width: width)
                .background(Color.background)
                .offset(x: max(profileOffset + profileDragOffset, 0))
                .gesture(
                    DragGesture()
                        .updating($profileDragOffset) { value, state, _ in
                            if value.translation.width > 0 { state = value.translation.width }
                        }
                        .onEnded { value in
                            if value.translation.width > width * 0.3 {
                                withAnimation {
                                    showProfileSheet = false
                                    profileOffset = 0
                                }
                            } else {
                                withAnimation { profileOffset = 0 }
                            }
                        }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .zIndex(10)
    }
}

#Preview {
    HomeView()
}
