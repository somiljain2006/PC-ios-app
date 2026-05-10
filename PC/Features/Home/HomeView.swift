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
    @Environment(\.scenePhase) private var scenePhase
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
                    case "askpc":
                        if #available(iOS 26.0, *) {
                            AskPCChatView(selectedTab: $selectedTab)
                        } else {
                            UnsupportedAIView()
                        }
                    default: homeContent
                    }
                }

                if selectedTab != "askpc" {
                    CustomBottomNavBar(selectedTab: $selectedTab)
                }
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
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            Task { await ProgressViewModel.refreshGitHubWidgetAfterForeground() }
        }
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

#Preview {
    HomeView()
}
