//
//  EditorialView.swift
//  PC
//
//  Created by somil jain on 23/04/26.
//

import Combine
import SwiftUI

struct EditorialPost: Identifiable, Hashable {
    let id: Int
    let date: String
    let title: String
    let platform: String
    let icon: String
    let questions: String
    let readTime: String
    let level: String
    let author: String
}

struct CFRecentActionsResponse: Codable {
    let status: String
    let result: [CFAction]
}

struct CFAction: Codable {
    let blogEntry: CFBlogEntry
}

struct CFBlogEntry: Codable {
    let id: Int
    let title: String
    let creationTimeSeconds: TimeInterval
    let authorHandle: String
}

struct PCEditorialsResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PCEditorial]
}

struct PCEditorial: Codable, Identifiable, Hashable {
    let id: Int
    let slug: String
    let platform: String
    let contestName: String
    let contestLink: String
    let contestDate: String
    let createdAt: String
    let questions: [PCQuestion]

    enum CodingKeys: String, CodingKey {
        case id, slug, platform
        case contestName = "contest_name"
        case contestLink = "contest_link"
        case contestDate = "contest_date"
        case createdAt = "created_at"
        case questions
    }
}

struct PCQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let questionName: String
    let questionLink: String

    enum CodingKeys: String, CodingKey {
        case id
        case questionName = "question_name"
        case questionLink = "question_link"
    }
}

@MainActor
class EditorialService: ObservableObject {
    @Published var posts: [EditorialPost] = []
    @Published var pcEditorials: [PCEditorial] = []

    @Published var isLoadingCF = true
    @Published var isLoadingPC = true

    func fetchAllData() async {
        async let fetchCF: () = fetchRecentCodeforcesBlogs()
        async let fetchPC: () = fetchPCEditorials()
        _ = await (fetchCF, fetchPC)
    }

    private func fetchRecentCodeforcesBlogs() async {
        isLoadingCF = true
        defer { isLoadingCF = false }

        guard let url = URL(string: "https://codeforces.com/api/recentActions?maxCount=100") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(CFRecentActionsResponse.self, from: data)

            var uniqueBlogs = [Int: CFBlogEntry]()
            for action in decodedResponse.result {
                uniqueBlogs[action.blogEntry.id] = action.blogEntry
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"

            let fetchedPosts: [EditorialPost] = uniqueBlogs.values.compactMap { blog in
                let cleanTitle = blog.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let lowerTitle = cleanTitle.lowercased()

                let isContestAnnouncement = (lowerTitle.contains("round") ||
                    lowerTitle.contains("div.") ||
                    lowerTitle.contains("contest")) &&
                    !lowerTitle.contains("editorial") &&
                    !lowerTitle.contains("tutorial")

                if isContestAnnouncement {
                    return nil
                }

                let date = Date(timeIntervalSince1970: blog.creationTimeSeconds)
                let randomQuestions = "\(Int.random(in: 3 ... 8)) Questions"
                let randomTime = "\(Int.random(in: 5 ... 25))m read"
                let randomLevel = ["Beginner", "Medium", "Hard", "Expert"].randomElement() ?? "Medium"

                return EditorialPost(
                    id: blog.id,
                    date: dateFormatter.string(from: date).uppercased(),
                    title: cleanTitle,
                    platform: "Codeforces",
                    icon: "code",
                    questions: randomQuestions,
                    readTime: randomTime,
                    level: randomLevel,
                    author: blog.authorHandle
                )
            }

            posts = Array(fetchedPosts.shuffled().prefix(10))

        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("Failed to fetch Codeforces blogs: \(error)")
            }
        }
    }

    private func fetchPCEditorials() async {
        isLoadingPC = true
        defer { isLoadingPC = false }

        guard let url = URL(string: "https://editorial.monu14.me/api/editorials/") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PCEditorialsResponse.self, from: data)
            pcEditorials = decodedResponse.results
        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("Failed to fetch PC Editorials: \(error)")
            }
        }
    }
}

struct EditorialView: View {
    @StateObject private var service = EditorialService()
    @FocusState private var isSearchFocused: Bool
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "All"

    private let filters = ["All", "CodeChef", "Codeforces", "LeetCode"]

    private var filteredPCList: [PCEditorial] {
        service.pcEditorials.filter { editorial in
            let mappedPlatform = getMappedPlatform(editorial.platform)
            let platformMatch = selectedFilter == "All" || mappedPlatform == selectedFilter
            let searchMatch = searchText.isEmpty || editorial.contestName.localizedCaseInsensitiveContains(searchText)
            return platformMatch && searchMatch
        }
    }

    private func getMappedPlatform(_ code: String) -> String {
        switch code {
        case "LC": "LeetCode"
        case "CC": "CodeChef"
        case "CF": "Codeforces"
        default: code
        }
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    featuredSection
                    searchAndFiltersSection
                    editorialListSection
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
                .onTapGesture {
                    isSearchFocused = false
                }
            }
            .refreshable {
                await service.fetchAllData()
            }
        }
        .task {
            if service.posts.isEmpty, service.pcEditorials.isEmpty {
                await service.fetchAllData()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Latest ")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.white)
                + Text("Editorials")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(Color.primaryContainer)

            Text("Read every contest breakdown in one place")
                .font(.system(size: 14))
                .foregroundColor(Color.onSurfaceVariant)
                .frame(maxWidth: 280, alignment: .leading)
        }
    }

    private var featuredSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                if service.isLoadingCF {
                    ForEach(0 ..< 3, id: \.self) { _ in
                        FeaturedBlogSkeleton()
                            .frame(width: 330, height: 200)
                    }
                } else if service.posts.isEmpty {
                    Text("No featured editorials found.")
                        .foregroundColor(.onSurfaceVariant)
                        .frame(width: 320, height: 200)
                } else {
                    ForEach(service.posts) { post in
                        FeaturedBlogCard(post: post)
                            .frame(width: 330)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, -16)
        .animation(.smooth, value: service.posts)
    }

    private var searchAndFiltersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.outline.opacity(0.5))

                TextField("Search editorials...", text: $searchText)
                    .foregroundColor(.white)
                    .tint(Color.primaryContainer)
                    .focused($isSearchFocused)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.outline.opacity(0.6))
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSearchActive ? Color.surfaceContainerHigh : Color.surfaceContainerLowest)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSearchActive ? Color.primaryContainer : Color.outlineVariant.opacity(0.2),
                        lineWidth: isSearchActive ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isSearchActive)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            withAnimation { selectedFilter = filter }
                        } label: {
                            Text(filter)
                                .font(.system(size: 12, weight: .bold))
                                .textCase(.uppercase)
                                .modifier(LetterSpacing(value: 1.5))
                                .foregroundColor(selectedFilter == filter ? Color.onPrimaryContainer : Color.onSurfaceVariant)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(selectedFilter == filter ? Color.primaryContainer : Color.surfaceContainerHigh)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .stroke(Color.outlineVariant.opacity(0.10), lineWidth: selectedFilter == filter ? 0 : 1)
                                )
                                .cornerRadius(999)
                        }
                    }
                }
            }
        }
    }

    private var isSearchActive: Bool {
        isSearchFocused || !searchText.isEmpty
    }

    private var editorialListSection: some View {
        VStack(spacing: 16) {
            if service.isLoadingPC {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if filteredPCList.isEmpty {
                Text("No editorials found for this filter.")
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.top, 20)
            } else {
                ForEach(filteredPCList) { editorial in
                    PCEditorialCard(editorial: editorial)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .animation(.smooth, value: filteredPCList)
    }
}

struct PCEditorialCard: View {
    let editorial: PCEditorial

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                HStack(spacing: 12) {
                    Image(getPlatformIcon(editorial.platform))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())

                    Text(editorial.contestName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.onSurface)
                }

                Spacer()

                Text(formatDate(editorial.contestDate))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.surfaceContainerHighest)
                    .cornerRadius(6)
            }

            Divider()
                .background(Color.outlineVariant.opacity(0.3))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(editorial.questions.enumerated()), id: \.element.id) { index, question in
                    let letter = String(UnicodeScalar(UInt8(65 + index)))
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(letter).")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primaryContainer)

                        Text(question.questionName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }
            }

            HStack {
                Spacer()

                Button {
                    if let url = URL(string: "https://www.programmingclub.live/editorials/\(editorial.slug)") {
                        UIApplication.shared.open(url)
                    } else if let fallbackUrl = URL(string: editorial.contestLink) {
                        UIApplication.shared.open(fallbackUrl)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("Open Editorial")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.primaryContainer)
                    .cornerRadius(999)
                }
            }
        }
        .padding(16)
        .background(Color.surfaceContainerLow)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.outlineVariant.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(16)
    }

    private func getPlatformIcon(_ platform: String) -> String {
        switch platform {
        case "LC": "leetcode"
        case "CC": "codechef"
        case "CF": "codeforces"
        case "AT": "atcoder"
        default: "globe"
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd MMM"
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct FeaturedBlogCard: View {
    let post: EditorialPost

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.secondaryContainer.opacity(0.30),
                    Color.primaryContainer.opacity(0.20),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)

            VStack(alignment: .leading, spacing: 14) {
                Text("FEATURED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.primary)
                    .textCase(.uppercase)
                    .modifier(LetterSpacing(value: 2))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.10))
                    .cornerRadius(4)

                Text(post.title)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                Text("\(post.readTime) • Level: \(post.level)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.onSurfaceVariant)
                    .lineLimit(1)

                HStack {
                    let initials = initials(from: post.author)

                    if initials.isEmpty {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.surfaceContainerHigh)
                            .overlay(
                                Circle().stroke(Color.surface, lineWidth: 2)
                            )
                            .clipShape(Circle())
                    } else {
                        Text(initials)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.surfaceContainerHigh)
                            .overlay(
                                Circle().stroke(Color.surface, lineWidth: 2)
                            )
                            .clipShape(Circle())
                    }

                    Text("@\(post.author)")
                        .font(.system(size: 12))
                        .foregroundColor(.outline)

                    Spacer()

                    Button {
                        if let url = URL(string: "https://codeforces.com/blog/entry/\(post.id)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("READ ARTICLE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.onPrimaryContainer)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.primaryContainer)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .frame(maxHeight: .infinity)
            .background(Color.surfaceContainerLow)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.outlineVariant.opacity(0.10), lineWidth: 1)
            )
        }
        .cornerRadius(12)
    }

    private func initials(from name: String) -> String {
        let letters = name.filter(\.isLetter)

        if letters.isEmpty {
            return ""
        } else if letters.count == 1 {
            return String(letters.prefix(1)).uppercased()
        } else {
            return String(letters.prefix(2)).uppercased()
        }
    }
}

struct FeaturedBlogSkeleton: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.surfaceContainerLow

            VStack(alignment: .leading, spacing: 14) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceContainerHigh)
                    .frame(width: 80, height: 12)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceContainerHigh)
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceContainerHigh)
                    .frame(height: 20)

                Spacer()

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceContainerHigh)
                    .frame(width: 140, height: 12)

                HStack {
                    Circle()
                        .fill(Color.surfaceContainerHigh)
                        .frame(width: 32, height: 32)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.surfaceContainerHigh)
                        .frame(width: 100, height: 12)

                    Spacer()
                }
            }
            .padding(20)
        }
        .overlay(
            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.11),
                    .clear,
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(20))
            .offset(x: animate ? 400 : -400)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
        .cornerRadius(12)
    }
}

#Preview {
    EditorialView()
}
