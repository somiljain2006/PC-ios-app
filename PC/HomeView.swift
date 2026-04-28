//
//  HomeView.swift
//  PC
//
//  Created by somil jain on 12/04/26.
//

import SwiftUI
import UIKit

func triggerHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.prepare()
    generator.impactOccurred()
}

class ProblemCache {
    static let shared = ProblemCache()
    var cfProblems: [CFProblem]?
    var acProblems: [ACProblem]?
}

struct UnifiedProblem: Identifiable, Codable {
    let id: UUID
    let name: String
    let platform: String
    let identifier: String
    let tags: [String]
    let url: URL?
    let icon: String

    init(
        id: UUID = UUID(),
        name: String,
        platform: String,
        identifier: String,
        tags: [String],
        url: URL?,
        icon: String
    ) {
        self.id = id
        self.name = name
        self.platform = platform
        self.identifier = identifier
        self.tags = tags
        self.url = url
        self.icon = icon
    }

    func copy() -> UnifiedProblem {
        UnifiedProblem(
            name: name,
            platform: platform,
            identifier: identifier,
            tags: tags,
            url: url,
            icon: icon
        )
    }
}

struct CFProblemResponse: Codable {
    let status: String
    let result: CFProblemResult
}

struct CFProblemResult: Codable {
    let problems: [CFProblem]
}

struct CFProblem: Codable {
    let contestId: Int?
    let index: String
    let name: String
    let tags: [String]

    var problemUrl: URL? {
        guard let cid = contestId else { return nil }
        return URL(string: "https://codeforces.com/problemset/problem/\(cid)/\(index)")
    }
}

struct CCProblemResponse: Codable {
    let status: String
    let data: [CCProblem]
}

struct CCProblem: Codable {
    let code: String
    let name: String

    var problemUrl: URL? {
        URL(string: "https://www.codechef.com/problems/\(code)")
    }
}

struct LCGraphQLResponse: Codable {
    let data: LCData
}

struct LCData: Codable {
    let activeDailyCodingChallengeQuestion: LCActiveQuestion
}

struct LCActiveQuestion: Codable {
    let date: String
    let link: String
    let question: LCQuestion
}

struct LCQuestion: Codable {
    let questionFrontendId: String
    let title: String
    let difficulty: String
    let topicTags: [LCTopicTag]
}

struct LCTopicTag: Codable {
    let name: String
}

struct ACProblem: Codable {
    let id: String
    let contestId: String
    let problemIndex: String
    let name: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case id
        case contestId = "contest_id"
        case problemIndex = "problem_index"
        case name
        case title
    }

    var problemUrl: URL? {
        URL(string: "https://atcoder.jp/contests/\(contestId)/tasks/\(id)")
    }
}

struct HomeView: View {
    @State private var selectedTab: String = "home"
    @StateObject private var network = NetworkMonitor()
    @State private var animateTitle = false
    @State private var glow = false

    @State private var challengeSlides: [UnifiedProblem] = []
    @State private var loopedSlides: [UnifiedProblem] = []
    @State private var isLoadingChallenge = false

    @State private var selectedSlideIndex: Int = 1
    @GestureState private var dragOffset: CGFloat = 0

    private var dailyChallengeTitle: String {
        guard loopedSlides.indices.contains(selectedSlideIndex) else {
            return "Daily Challenges"
        }
        let slide = loopedSlides[selectedSlideIndex]
        if slide.platform.starts(with: "Daily Pick") {
            return "Daily Challenge"
        } else {
            return "Daily \(slide.platform) Challenge"
        }
    }

    private var realIndex: Int {
        let count = challengeSlides.count
        guard count > 0 else { return 0 }

        if selectedSlideIndex == 0 {
            return count - 1
        } else if selectedSlideIndex == loopedSlides.count - 1 {
            return 0
        } else {
            return selectedSlideIndex - 1
        }
    }

    private var isPinnedCardSelected: Bool {
        guard PinnedChallengeManager.load() != nil else { return false }
        return realIndex == 0
    }

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
        .task {
            if challengeSlides.isEmpty {
                await loadAllChallenges()
            }
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
                        withAnimation(.easeOut(duration: 0.6)) { animateTitle = true }
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
                    HStack {
                        Text(dailyChallengeTitle)
                            .font(.headline)
                            .foregroundColor(.onSurface)
                            .animation(.easeInOut, value: selectedSlideIndex)

                        Spacer()

                        if isLoadingChallenge {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            if isPinnedCardSelected {
                                Button {
                                    PinnedChallengeManager.clear()
                                    Task { await loadAllChallenges() }
                                } label: {
                                    Image(systemName: "pin.slash")
                                        .foregroundColor(.primaryContainer)
                                }
                            }
                            Button {
                                Task { await loadAllChallenges() }
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.primaryContainer)
                                    .padding(8)
                                    .background(Color.surfaceContainerHigh)
                                    .clipShape(Circle())
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
                                                    Task { await loadAllChallenges() }
                                                } else {
                                                    PinnedChallengeManager.save(selected)
                                                    Task { await loadAllChallenges() }
                                                }
                                            }
                                        )
                                        .frame(width: cardWidth)
                                    }
                                }
                                .padding(.leading, leadingPadding)
                                .offset(x: -(CGFloat(selectedSlideIndex) * (cardWidth + spacing)))
                                .offset(x: dragOffset)
                                .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: dragOffset)
                                .gesture(
                                    DragGesture(minimumDistance: 15)
                                        .updating($dragOffset) { value, state, _ in
                                            state = value.translation.width
                                        }
                                        .onEnded { value in
                                            let swipeDistance = value.predictedEndTranslation.width
                                            var newIndex = selectedSlideIndex

                                            if swipeDistance < -cardWidth / 3 {
                                                newIndex = min(loopedSlides.count - 1, selectedSlideIndex + 1)
                                            } else if swipeDistance > cardWidth / 3 {
                                                newIndex = max(0, selectedSlideIndex - 1)
                                            }

                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                                selectedSlideIndex = newIndex
                                            }
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
                                } else if newValue == count - 1 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                        selectedSlideIndex = 1
                                    }
                                }
                            }
                            .padding(.horizontal, -16)
                            .clipped()
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                        }
                    } else if !isLoadingChallenge {
                        Text("Connect to the internet to get today's challenge.")
                            .font(.caption)
                            .foregroundColor(.onSurfaceVariant)
                            .padding(.vertical, 20)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.surfaceContainerHigh)
                            .frame(height: 180)
                    }
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

    private func loadAllChallenges() async {
        isLoadingChallenge = true
        defer { isLoadingChallenge = false }

        async let cf = fetchCodeforcesProblem()
        async let cc = fetchCodeChefProblem()
        async let lc = fetchLeetCodeProblem()
        async let ac = fetchAtCoderProblem()

        let (fetchedCF, fetchedCC, fetchedLC, fetchedAC) = await (cf, cc, lc, ac)

        var slides: [UnifiedProblem] = []

        if let fetchedCF { slides.append(fetchedCF) }
        if let fetchedCC { slides.append(fetchedCC) }
        if let fetchedAC { slides.append(fetchedAC) }
        if let fetchedLC { slides.append(fetchedLC) }

        if let pinned = PinnedChallengeManager.load() {
            slides.removeAll { pinned.platform.contains($0.platform) }

            slides.insert(pinned.copy(), at: 0)
        } else {
            if let randomDefault = slides.randomElement() {
                let dp = UnifiedProblem(
                    name: randomDefault.name,
                    platform: "Daily Pick (\(randomDefault.platform))",
                    identifier: randomDefault.identifier,
                    tags: randomDefault.tags,
                    url: randomDefault.url,
                    icon: randomDefault.icon
                )
                slides.insert(dp, at: 0)
            }
        }

        var ghosts = slides
        if let first = slides.first, let last = slides.last {
            ghosts.insert(last.copy(), at: 0)
            ghosts.append(first.copy())
        }

        withAnimation(.easeInOut) {
            challengeSlides = slides
            loopedSlides = ghosts
            selectedSlideIndex = 1
        }
    }

    private func fetchCodeforcesProblem() async -> UnifiedProblem? {
        if let cached = ProblemCache.shared.cfProblems, let randomProblem = cached.randomElement() {
            return mapCF(randomProblem)
        }

        guard let url = URL(string: "https://codeforces.com/api/problemset.problems") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(CFProblemResponse.self, from: data)
            ProblemCache.shared.cfProblems = decoded.result.problems
            if let randomProblem = decoded.result.problems.randomElement() {
                return mapCF(randomProblem)
            }
        } catch {
            print("Failed to fetch CF: \(error.localizedDescription)")
        }
        return nil
    }

    private func fetchCodeChefProblem() async -> UnifiedProblem? {
        let randomPage = Int.random(in: 1 ... 50)
        guard let url = URL(string: "https://www.codechef.com/api/list/problems?page=\(randomPage)&limit=50") else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko)", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(CCProblemResponse.self, from: data)

            if let randomProblem = decoded.data.randomElement() {
                return UnifiedProblem(
                    name: randomProblem.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    platform: "CodeChef",
                    identifier: randomProblem.code,
                    tags: ["Practice", "CodeChef"],
                    url: randomProblem.problemUrl,
                    icon: "codechef"
                )
            }
        } catch {
            print("Failed to fetch CodeChef: \(error.localizedDescription)")
        }
        return nil
    }

    private func fetchLeetCodeProblem() async -> UnifiedProblem? {
        guard let url = URL(string: "https://leetcode.com/graphql") else { return nil }

        let queryBody = """
        {
            "query": "query { activeDailyCodingChallengeQuestion { date link question { questionFrontendId title difficulty topicTags { name } } } }"
        }
        """

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = queryBody.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(LCGraphQLResponse.self, from: data)

            let challengeData = decoded.data.activeDailyCodingChallengeQuestion
            let question = challengeData.question

            let mappedTags = question.topicTags.map(\.name)
            var finalTags = Array(mappedTags.prefix(3))
            if finalTags.count < 3 { finalTags.append(question.difficulty) }

            return UnifiedProblem(
                name: question.title,
                platform: "LeetCode",
                identifier: "Daily \(challengeData.date)",
                tags: finalTags,
                url: URL(string: "https://leetcode.com\(challengeData.link)"),
                icon: "leetcode"
            )
        } catch {
            print("Failed to fetch LeetCode: \(error.localizedDescription)")
        }
        return nil
    }

    private func fetchAtCoderProblem() async -> UnifiedProblem? {
        if let cached = ProblemCache.shared.acProblems, let randomProblem = cached.randomElement() {
            return mapAC(randomProblem)
        }

        guard let url = URL(string: "https://kenkoooo.com/atcoder/resources/problems.json") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode([ACProblem].self, from: data)
            ProblemCache.shared.acProblems = decoded
            if let randomProblem = decoded.randomElement() {
                return mapAC(randomProblem)
            }
        } catch {
            print("Failed to fetch AtCoder: \(error.localizedDescription)")
        }
        return nil
    }

    private func mapCF(_ problem: CFProblem) -> UnifiedProblem {
        UnifiedProblem(
            name: problem.name,
            platform: "Codeforces",
            identifier: "\(problem.contestId ?? 0)\(problem.index)",
            tags: Array(problem.tags.prefix(3)),
            url: problem.problemUrl,
            icon: "codeforces"
        )
    }

    private func mapAC(_ problem: ACProblem) -> UnifiedProblem {
        UnifiedProblem(
            name: problem.name,
            platform: "AtCoder",
            identifier: "\(problem.contestId) \(problem.problemIndex)",
            tags: ["AtCoder", "Practice"],
            url: problem.problemUrl,
            icon: "atcoder"
        )
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

struct DailyChallengeCard: View {
    let problem: UnifiedProblem
    let onTogglePin: (UnifiedProblem) -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(problem.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.onSurface)
                        .lineLimit(2)

                    Text("\(problem.platform) • \(problem.identifier)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)

                    FlowLayout(data: problem.tags) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .semibold))
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

class PinnedChallengeManager {
    private static let key = "pinned_challenge"

    static func save(_ problem: UnifiedProblem) {
        if let data = try? JSONEncoder().encode(problem) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> UnifiedProblem? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let problem = try? JSONDecoder().decode(UnifiedProblem.self, from: data)
        else { return nil }

        return problem
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

#Preview {
    HomeView()
}
