//
//  Models.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import Foundation
import SwiftUI

struct ActiveImage: Identifiable {
    let id = UUID()
    let name: String
}

struct AppContest: Hashable, Identifiable {
    var id: String {
        "\(platform)_\(title)_\(startTime.timeIntervalSince1970)"
    }

    let title: String
    let platform: String
    let icon: String
    let startTime: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: startTime)
    }

    var shortTitle: String {
        let lower = title.lowercased()

        if platform == "AtCoder" {
            if lower.contains("beginner contest") {
                if let number = extractNumber() {
                    return "AtCoder Beginner Contest \(number)"
                }
                return "AtCoder Beginner Contest"
            }

            if lower.contains("regular contest") {
                if let number = extractNumber() {
                    return "AtCoder Regular Contest \(number)"
                }
                return "AtCoder Regular Contest"
            }

            if lower.contains("grand contest") {
                if let number = extractNumber() {
                    return "AtCoder Grand Contest \(number)"
                }
                return "AtCoder Grand Contest"
            }
        }

        if platform == "CodeChef" {
            if lower.contains("starters") {
                if let number = extractNumber() {
                    return "Starters \(number)"
                }
                return "CodeChef Starters"
            }
        }

        return title
    }

    private func extractNumber() -> String? {
        let regex = try? NSRegularExpression(pattern: "\\d+")
        let nsString = title as NSString
        let match = regex?.firstMatch(in: title, range: NSRange(location: 0, length: nsString.length))
        if let match {
            return nsString.substring(with: match.range)
        }
        return nil
    }
}

struct LeetCodeResponse: Decodable {
    let data: LeetCodeData
}

struct LeetCodeData: Decodable {
    let topTwoContests: [LeetCodeContest]
}

struct LeetCodeContest: Decodable {
    let title: String
    let startTime: Int
}

struct CodeChefResponse: Decodable {
    let futureContests: [CodeChefContest]

    enum CodingKeys: String, CodingKey {
        case futureContests = "future_contests"
    }
}

struct CodeChefContest: Decodable {
    let contestName: String
    let contestStartDateIso: String

    enum CodingKeys: String, CodingKey {
        case contestName = "contest_name"
        case contestStartDateIso = "contest_start_date_iso"
    }
}

struct CodeforcesResponse: Decodable {
    let status: String
    let result: [CodeforcesContest]
}

struct CodeforcesContest: Decodable {
    let id: Int
    let name: String
    let phase: String
    let startTimeSeconds: Int?
}

struct ContestFilter: Hashable {
    let name: String
    let icon: String?
}

struct PCEditorialDetail: Codable, Identifiable, Hashable {
    let id: Int
    let slug: String
    let platform: String
    let contestName: String
    let contestLink: String
    let contestDate: String
    let createdAt: String
    let questions: [PCEditorialDetailQuestion]

    enum CodingKeys: String, CodingKey {
        case id, slug, platform
        case contestName = "contest_name"
        case contestLink = "contest_link"
        case contestDate = "contest_date"
        case createdAt = "created_at"
        case questions
    }
}

struct PCEditorialDetailQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let questionName: String
    let questionLink: String
    let explanation: String?
    let code: String?

    enum CodingKeys: String, CodingKey {
        case id
        case questionName = "question_name"
        case questionLink = "question_link"
        case explanation
        case code
    }
}

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
