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

        let counts = calendar.weeks
            .flatMap(\.contributionDays)
            .map(\.contributionCount)

        let heatmap = Array(counts.suffix(105)).map(\.githubHeatLevel)

        return GitHubStats(
            contributions: calendar.totalContributions,
            heatmap: heatmap,
            currentStreak: calculateCurrentStreak(counts: counts),
            maxStreak: calculateMaxStreak(counts: counts)
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
