//
//  ProgressModels.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import Foundation
import SwiftUI

struct GitHubHeatmapMonthAxis: Equatable {
    let left: String
    let center: String
    let right: String

    static let empty = GitHubHeatmapMonthAxis(left: "", center: "", right: "")
}

struct GitHubStats {
    static let mainHeatmapContributionDayCount = 105
    static let largeWidgetContributionDayCount = 210

    let contributions: Int
    let heatmap: [HeatLevel]

    let heatmapMonthAxis: GitHubHeatmapMonthAxis

    let largeWidgetHeatmapLevels: [Int]
    let largeWidgetMonths: [String]

    let currentStreak: Int
    let maxStreak: Int

    enum HeatLevel {
        case none, low, medium, high

        var color: Color {
            switch self {
            case .none:
                Color.surfaceContainerHighest
            case .low:
                Color.green.opacity(0.3)
            case .medium:
                Color.green.opacity(0.6)
            case .high:
                Color.green
            }
        }
    }

    static func empty(count: Int = 105) -> GitHubStats {
        GitHubStats(
            contributions: 0,
            heatmap: Array(repeating: .none, count: count),
            heatmapMonthAxis: .empty,
            largeWidgetHeatmapLevels: [],
            largeWidgetMonths: ["", "", "", "", "", ""],
            currentStreak: 0,
            maxStreak: 0
        )
    }
}

struct LeetCodeStats {
    let badge: String

    let totalSolved: Int
    let totalQuestions: Int

    let ranking: Int

    let easySolved: Int
    let mediumSolved: Int
    let hardSolved: Int

    let easyTotal: Int
    let mediumTotal: Int
    let hardTotal: Int

    let currentStreak: Int
    let maxStreak: Int

    var easyProgress: Double {
        Double(easySolved) / Double(max(easyTotal, 1))
    }

    var mediumProgress: Double {
        Double(mediumSolved) / Double(max(mediumTotal, 1))
    }

    var hardProgress: Double {
        Double(hardSolved) / Double(max(hardTotal, 1))
    }
}

struct RatedPlatformStats: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let accent: Color
    let badge: String
    let rating: Int
    let peak: Int
    let monthlyGain: Int
    let currentStreak: Int?
    let maxStreak: Int?
}

struct AtCoderStats {
    let badge: String
    let accentColor: Color
    let rating: Int
    let ratingGoal: Int

    var progress: Double {
        Double(rating) / Double(ratingGoal)
    }

    var progressLabel: String {
        "\(rating)/\(ratingGoal)"
    }
}

extension [RatedPlatformStats] {
    static let empty: [RatedPlatformStats] = []
}

extension AtCoderStats {
    static let empty = AtCoderStats(
        badge: "N/A", accentColor: .gray, rating: 0, ratingGoal: 1600
    )
}

extension LeetCodeStats {
    static let empty = LeetCodeStats(
        badge: "N/A", totalSolved: 0, totalQuestions: 3500, ranking: 0,
        easySolved: 0, mediumSolved: 0, hardSolved: 0, easyTotal: 850,
        mediumTotal: 1800, hardTotal: 850, currentStreak: 0, maxStreak: 0
    )
}

struct CodeChefParsedData {
    let currentRating: Int
    let highestRating: Int
    let stars: String
}

struct GitHubUserResponse: Decodable {
    let publicRepos: Int
    enum CodingKeys: String, CodingKey { case publicRepos = "public_repos" }
}

struct CFUserInfoResponse: Decodable { let result: [CFUser] }
struct CFStatusResponse: Decodable { let result: [CFSubmission] }
struct CFRatingResponse: Decodable { let result: [CFRatingChange] }

struct CFUser: Decodable {
    let rating: Int
    let maxRating: Int
    let rank: String
}

struct CFRatingChange: Decodable {
    let ratingUpdateTimeSeconds: Int
    let newRating: Int
}

struct CFSubmission: Decodable {
    let creationTimeSeconds: Int
    let verdict: String?
}

struct CodeChefUserResponse: Decodable {
    let currentRating: Int
    let highestRating: Int
    let stars: String
}

struct AtCoderHistoryResponse: Decodable {
    let newRating: Int
    enum CodingKeys: String, CodingKey { case newRating = "NewRating" }

    var color: String {
        switch newRating {
        case 0 ..< 400: "Gray"
        case 400 ..< 800: "Brown"
        case 800 ..< 1200: "Green"
        case 1200 ..< 1600: "Cyan"
        case 1600 ..< 2000: "Blue"
        case 2000 ..< 2400: "Yellow"
        case 2400 ..< 2800: "Orange"
        default: "Red"
        }
    }
}

struct LeetCodeGraphQLRequest: Encodable {
    let query: String
    let variables: Variables
    struct Variables: Encodable { let username: String }
}

struct LeetCodeGraphQLResponse: Decodable { let data: LeetCodeUserData }
struct LeetCodeUserData: Decodable {
    let matchedUser: LeetCodeMatchedUser
    let allQuestionsCount: [LeetCodeQuestionCount]
}

struct LeetCodeMatchedUser: Decodable {
    let username: String
    let submitStats: LeetCodeSubmitStats
    let profile: LeetCodeProfile
}

struct LeetCodeProfile: Decodable { let ranking: Int }
struct LeetCodeSubmitStats: Decodable { let acSubmissionNum: [LeetCodeSubmission] }
struct LeetCodeSubmission: Decodable {
    let difficulty: String
    let count: Int
    let submissions: Int
}

struct LeetCodeQuestionCount: Decodable {
    let difficulty: String
    let count: Int
}
