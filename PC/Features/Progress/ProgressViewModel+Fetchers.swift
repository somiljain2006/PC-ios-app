//
//  ProgressViewModel+Fetchers.swift
//  PC
//
//  Created by somil jain on 09/05/26.
//

import Combine
import SwiftUI
import WidgetKit

extension ProgressViewModel {
    static func refreshGitHubWidgetAfterForeground() async {
        let username = UserDefaults.standard.string(forKey: "github_username") ?? ""
        let token = UserDefaults.standard.string(forKey: "github_token") ?? ""
        guard !username.isEmpty, !token.isEmpty else { return }

        do {
            let stats = try await GitHubService.shared.fetchContributionData(username: username, token: token)
            persistGitHubWidgetData(stats: stats)
        } catch is CancellationError {
        } catch {
            print("GitHub widget foreground refresh failed:", error)
        }
    }

    private static func persistGitHubWidgetData(stats: GitHubStats) {
        let shared = UserDefaults(suiteName: "group.com.pc.app")
        let payload = WidgetPlatformData(
            title: "GitHub",
            primaryValue: "\(stats.contributions)",
            secondaryValue: "Contributions",
            accent: "green",
            currentStreak: stats.currentStreak,
            maxStreak: stats.maxStreak,
            heatmapLevels: stats.heatmap.map { level in
                switch level {
                case .none: 0
                case .low: 1
                case .medium: 2
                case .high: 3
                }
            },
            githubMonthLeft: stats.heatmapMonthAxis.left,
            githubMonthCenter: stats.heatmapMonthAxis.center,
            githubMonthRight: stats.heatmapMonthAxis.right,
            heatmapLevelsLarge: stats.largeWidgetHeatmapLevels,
            githubLargeMonths: stats.largeWidgetMonths
        )
        guard let encoded = try? JSONEncoder().encode(payload) else { return }
        shared?.set(encoded, forKey: "github_widget")
        WidgetCenter.shared.reloadTimelines(ofKind: "GitHubActivityWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "PCWidgets")
    }

    func fetchGitHub() async {
        let username = UserDefaults.standard.string(forKey: "github_username") ?? ""
        let token = UserDefaults.standard.string(forKey: "github_token") ?? ""

        guard !username.isEmpty, !token.isEmpty else { return }

        do {
            let stats = try await GitHubService.shared.fetchContributionData(username: username, token: token)
            updateGitHub(stats)
            Self.persistGitHubWidgetData(stats: stats)
        } catch is CancellationError { } catch { print("GitHub fetch failed:", error) }
    }

    func fetchAtCoder() async {
        guard let handle = handles.atcoder?.trimmingCharacters(in: .whitespacesAndNewlines), !handle.isEmpty,
              let url = URL(string: "https://atcoder.jp/users/\(handle)/history/json") else { return }

        do {
            var request = URLRequest(url: url)
            request.setValue("PCApp/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
            let (data, _) = try await URLSession.shared.data(for: request)

            let history = try JSONDecoder().decode([AtCoderHistoryResponse].self, from: data)
            guard let latest = history.last else { return }

            updateAtCoder(AtCoderStats(badge: latest.color, accentColor: .cyan, rating: latest.newRating, ratingGoal: 1600))
            saveWidgetData(
                key: "atcoder_widget",
                data: WidgetPlatformData(
                    title: "AtCoder", primaryValue: "\(atcoder.rating)", secondaryValue: atcoder.badge,
                    accent: "cyan", currentStreak: nil, maxStreak: nil
                )
            )
            WidgetCenter.shared.reloadAllTimelines()
        } catch { print("AtCoder fetch failed:", error) }
    }

    static let leetCodeQuery = """
    query userProblemsSolved($username: String!) {
      matchedUser(username: $username) {
        username
        submitStats { acSubmissionNum { difficulty count submissions } }
        profile { ranking }
      }
      allQuestionsCount { difficulty count }
    }
    """

    func fetchLeetCode() async {
        guard let username = handles.leetcode?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty else { return }
        do {
            let decoded = try await performLeetCodeRequest(for: username)
            updateLeetCode(createLeetCodeStats(from: decoded))
            updateLeetCodeWidget(with: leetcode)
        } catch is CancellationError { } catch { print("LeetCode fetch failed:", error) }
    }

    private func performLeetCodeRequest(for username: String) async throws -> LeetCodeGraphQLResponse {
        guard let url = URL(string: "https://leetcode.com/graphql") else { throw URLError(.badURL) }
        let body = LeetCodeGraphQLRequest(query: Self.leetCodeQuery, variables: .init(username: username))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(LeetCodeGraphQLResponse.self, from: data)
    }

    private func createLeetCodeStats(from decoded: LeetCodeGraphQLResponse) -> LeetCodeStats {
        let stats = decoded.data.matchedUser.submitStats.acSubmissionNum
        let all = stats.first(where: { $0.difficulty == "All" })?.count ?? 0
        let easy = stats.first(where: { $0.difficulty == "Easy" })?.count ?? 0
        let medium = stats.first(where: { $0.difficulty == "Medium" })?.count ?? 0
        let hard = stats.first(where: { $0.difficulty == "Hard" })?.count ?? 0
        let ranking = decoded.data.matchedUser.profile.ranking
        let totals = leetCodeQuestionTotals(from: decoded.data.allQuestionsCount)

        let badge = switch ranking {
        case 0 ..< 5000: "Top 1%"
        case 0 ..< 25000: "Top 5%"
        case 0 ..< 50000: "Top 10%"
        default: "Active"
        }

        return LeetCodeStats(
            badge: badge, totalSolved: all, totalQuestions: totals.totalQuestions, ranking: ranking,
            easySolved: easy, mediumSolved: medium, hardSolved: hard, easyTotal: totals.easyTotal,
            mediumTotal: totals.mediumTotal, hardTotal: totals.hardTotal, currentStreak: 0, maxStreak: 0
        )
    }

    private func updateLeetCodeWidget(with stats: LeetCodeStats) {
        saveWidgetData(
            key: "leetcode_widget",
            data: WidgetPlatformData(
                title: "LeetCode", primaryValue: "\(stats.totalSolved)", secondaryValue: stats.badge, accent: "orange",
                currentStreak: stats.currentStreak, maxStreak: stats.maxStreak, easySolved: stats.easySolved,
                mediumSolved: stats.mediumSolved, hardSolved: stats.hardSolved
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    struct LeetCodeQuestionTotals {
        let totalQuestions: Int; let easyTotal: Int; let mediumTotal: Int; let hardTotal: Int
    }

    private func leetCodeQuestionTotals(from questionCounts: [LeetCodeQuestionCount]) -> LeetCodeQuestionTotals {
        LeetCodeQuestionTotals(
            totalQuestions: questionCounts.first(where: { $0.difficulty == "All" })?.count ?? 3500,
            easyTotal: questionCounts.first(where: { $0.difficulty == "Easy" })?.count ?? 850,
            mediumTotal: questionCounts.first(where: { $0.difficulty == "Medium" })?.count ?? 1800,
            hardTotal: questionCounts.first(where: { $0.difficulty == "Hard" })?.count ?? 850
        )
    }

    func fetchCodeforces() async {
        guard let handle = handles.codeforces?.trimmingCharacters(in: .whitespacesAndNewlines), !handle.isEmpty else { return }
        do {
            let networkData = try await fetchCFNetworkData(for: handle)
            let userResponse = try JSONDecoder().decode(CFUserInfoResponse.self, from: networkData.info)
            guard let user = userResponse.result.first else { return }

            let submissions = try JSONDecoder().decode(CFStatusResponse.self, from: networkData.status)
            let streaks = calculateCFStreaks(from: submissions.result)
            let ratingHistory = try JSONDecoder().decode(CFRatingResponse.self, from: networkData.rating)
            let monthlyGain = calculateCFMonthlyGain(history: ratingHistory, currentRating: user.rating)

            let cfStats = RatedPlatformStats(
                title: "Codeforces", icon: "chart.xyaxis.line", accent: .red,
                badge: user.rank.capitalized, rating: user.rating, peak: user.maxRating,
                monthlyGain: monthlyGain, currentStreak: streaks.current, maxStreak: streaks.max
            )
            updateCFStateAndWidget(cfStats)

        } catch is CancellationError { } catch { print("Codeforces fetch failed:", error) }
    }

    struct CFNetworkData { let info: Data; let status: Data; let rating: Data }

    private func fetchCFNetworkData(for handle: String) async throws -> CFNetworkData {
        guard let infoURL = URL(string: "https://codeforces.com/api/user.info?handles=\(handle)"),
              let statusURL = URL(string: "https://codeforces.com/api/user.status?handle=\(handle)"),
              let ratingURL = URL(string: "https://codeforces.com/api/user.rating?handle=\(handle)")
        else { throw URLError(.badURL) }

        async let infoTask = URLSession.shared.data(for: createCFRequest(url: infoURL))
        async let statusTask = URLSession.shared.data(for: createCFRequest(url: statusURL))
        async let ratingTask = URLSession.shared.data(for: createCFRequest(url: ratingURL))

        let (infoRes, statusRes, ratingRes) = try await (infoTask, statusTask, ratingTask)
        return CFNetworkData(info: infoRes.0, status: statusRes.0, rating: ratingRes.0)
    }

    private func createCFRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("PCApp/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        return request
    }

    private func calculateCFMonthlyGain(history: CFRatingResponse, currentRating: Int) -> Int {
        let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recent = history.result.last?.newRating ?? currentRating
        let oldRating = history.result.last(where: { Date(timeIntervalSince1970: TimeInterval($0.ratingUpdateTimeSeconds)) < monthAgo })?.newRating ?? recent
        return recent - oldRating
    }

    func calculateCFStreaks(from submissions: [CFSubmission]) -> (current: Int, max: Int) {
        let calendar = Calendar.current
        let uniqueDays = Set(submissions.filter { $0.verdict == "OK" }
            .map { calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval($0.creationTimeSeconds))) })
        let sortedDays = uniqueDays.sorted()

        guard !sortedDays.isEmpty else { return (0, 0) }

        var maxStreak = 1; var currentStreak = 1; var running = 1

        for dayIndex in 1 ..< sortedDays.count {
            if calendar.dateComponents([.day], from: sortedDays[dayIndex - 1], to: sortedDays[dayIndex]).day == 1 {
                running += 1
            } else { running = 1 }
            maxStreak = max(maxStreak, running)
        }

        var cursor = calendar.startOfDay(for: Date())
        currentStreak = 0
        while uniqueDays.contains(cursor) {
            currentStreak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return (currentStreak, maxStreak)
    }

    private func updateCFStateAndWidget(_ cf: RatedPlatformStats) {
        upsertPlatform(cf, insertAtStart: true)
        let widgetData = WidgetPlatformData(
            title: "Codeforces", primaryValue: "\(cf.rating)", secondaryValue: cf.badge, accent: "red",
            currentStreak: cf.currentStreak, maxStreak: cf.maxStreak, peakRating: cf.peak, monthlyGain: cf.monthlyGain
        )
        saveWidgetData(key: "codeforces_widget", data: widgetData)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
