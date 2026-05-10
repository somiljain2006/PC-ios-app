//
//  GitHubService.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import Foundation

final class GitHubService {
    static let shared = GitHubService()

    private init() {}

    func fetchContributionData(
        username: String,
        token: String
    ) async throws -> GitHubStats {
        let request = try buildRequest(username: username, token: token)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard http.statusCode == 200 else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("GitHub API Error:", responseString)
            }
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder()
            .decode(GitHubGraphQLResponse.self, from: data)

        let calendar = decoded.data.user.contributionsCollection.contributionCalendar

        let allDays = calendar.weeks.flatMap(\.contributionDays)
        let fullCounts = allDays.map(\.contributionCount)
        let days = Array(allDays.suffix(GitHubStats.mainHeatmapContributionDayCount))
        let counts = days.map(\.contributionCount)

        let heatmap = counts.map(\.githubHeatLevel)
        let dayWeeks = days.chunked(into: 7)
        let heatmapMonthAxis = Self.monthAxis(forWeeks: dayWeeks)

        let extendedDays = Array(allDays.suffix(GitHubStats.largeWidgetContributionDayCount))
        let largeWidgetHeatmapLevels = extendedDays.map(\.contributionCount).map(Self.heatmapLevelInt(forCount:))
        let largeDayWeeks = extendedDays.chunked(into: 7)
        let largeWidgetMonths = Self.monthLabels(forWeeks: largeDayWeeks)

        return GitHubStats(
            contributions: calendar.totalContributions,
            heatmap: heatmap,
            heatmapMonthAxis: heatmapMonthAxis,
            largeWidgetHeatmapLevels: largeWidgetHeatmapLevels,
            largeWidgetMonths: largeWidgetMonths,
            currentStreak: calculateCurrentStreak(counts: fullCounts),
            maxStreak: calculateMaxStreak(counts: fullCounts)
        )
    }

    private func buildRequest(username: String, token: String) throws -> URLRequest {
        let query = """
        query($login:String!) {
          user(login:$login) {
            contributionsCollection {
              contributionCalendar {
                totalContributions
                weeks {
                  contributionDays {
                    contributionCount
                    date
                  }
                }
              }
            }
          }
        }
        """

        let body = GitHubGraphQLRequest(
            query: query,
            variables: .init(login: username)
        )

        guard let url = URL(string: "https://api.github.com/graphql") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("PCApp/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONEncoder().encode(body)

        return request
    }

    private static func heatmapLevelInt(forCount count: Int) -> Int {
        switch count {
        case 0: 0
        case 1 ... 3: 1
        case 4 ... 7: 2
        default: 3
        }
    }

    private static let contributionDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func monthAxis(forWeeks dayWeeks: [[ContributionDay]]) -> GitHubHeatmapMonthAxis {
        guard !dayWeeks.isEmpty,
              let firstDay = dayWeeks[0].first,
              let startDate = contributionDayFormatter.date(from: firstDay.date)
        else {
            return .empty
        }

        let labelFormatter = DateFormatter()
        labelFormatter.locale = Locale.autoupdatingCurrent
        labelFormatter.setLocalizedDateFormatFromTemplate("MMM")

        let weekCount = dayWeeks.count
        let middleIndex = min(max(weekCount / 2, 0), weekCount - 1)
        let middleDate: Date = {
            guard let day = dayWeeks[middleIndex].first,
                  let date = Self.contributionDayFormatter.date(from: day.date)
            else { return startDate }
            return date
        }()

        let endDate: Date = {
            guard let lastDay = dayWeeks[weekCount - 1].last,
                  let date = Self.contributionDayFormatter.date(from: lastDay.date)
            else { return startDate }
            return date
        }()

        return GitHubHeatmapMonthAxis(
            left: labelFormatter.string(from: startDate).uppercased(),
            center: labelFormatter.string(from: middleDate).uppercased(),
            right: labelFormatter.string(from: endDate).uppercased()
        )
    }

    private static func monthLabels(forWeeks dayWeeks: [[ContributionDay]]) -> [String] {
        let weekCount = dayWeeks.count
        guard weekCount > 0 else {
            return ["", "", "", "", "", ""]
        }

        let labelFormatter = DateFormatter()
        labelFormatter.locale = Locale.autoupdatingCurrent
        labelFormatter.setLocalizedDateFormatFromTemplate("MMM")

        func monthUpper(weekIndex: Int, useFirstDayOfWeek: Bool) -> String {
            guard weekIndex >= 0, weekIndex < weekCount else { return "" }
            let day: ContributionDay? = useFirstDayOfWeek
                ? dayWeeks[weekIndex].first
                : dayWeeks[weekIndex].last
            guard let day,
                  let date = Self.contributionDayFormatter.date(from: day.date)
            else { return "" }
            return labelFormatter.string(from: date).uppercased()
        }

        let lastIndex = weekCount - 1
        let i0 = 0
        let i1 = max(0, lastIndex / 5)
        let i2 = max(0, lastIndex * 2 / 5)
        let i3 = max(0, lastIndex * 3 / 5)
        let i4 = max(0, lastIndex * 4 / 5)

        return [
            monthUpper(weekIndex: i0, useFirstDayOfWeek: true),
            monthUpper(weekIndex: i1, useFirstDayOfWeek: true),
            monthUpper(weekIndex: i2, useFirstDayOfWeek: true),
            monthUpper(weekIndex: i3, useFirstDayOfWeek: true),
            monthUpper(weekIndex: i4, useFirstDayOfWeek: true),
            monthUpper(weekIndex: lastIndex, useFirstDayOfWeek: false),
        ]
    }

    private func calculateCurrentStreak(counts: [Int]) -> Int {
        var currentStreak = 0
        for count in counts.reversed() {
            if count > 0 {
                currentStreak += 1
            } else {
                break
            }
        }
        return currentStreak
    }

    private func calculateMaxStreak(counts: [Int]) -> Int {
        var maxStreak = 0
        var running = 0
        for count in counts {
            if count > 0 {
                running += 1
                maxStreak = max(maxStreak, running)
            } else {
                running = 0
            }
        }
        return maxStreak
    }
}

private extension [ContributionDay] {
    func chunked(into size: Int) -> [[ContributionDay]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

private extension Int {
    var githubHeatLevel: GitHubStats.HeatLevel {
        switch self {
        case 0:
            .none
        case 1 ... 3:
            .low
        case 4 ... 7:
            .medium
        default:
            .high
        }
    }
}
