//
//  ProblemService.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Foundation
import UIKit

final class ProblemService {
    static let shared = ProblemService()

    private init() {}

    func loadAllChallenges() async -> [UnifiedProblem] {
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
        } else if let randomDefault = slides.randomElement() {
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

        return slides
    }

    private func fetchCodeforcesProblem() async -> UnifiedProblem? {
        if let cached = ProblemCache.shared.cfProblems,
           let random = cached.randomElement()
        {
            return mapCF(random)
        }

        guard let url = URL(string: "https://codeforces.com/api/problemset.problems") else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(CFProblemResponse.self, from: data)
            ProblemCache.shared.cfProblems = decoded.result.problems

            return decoded.result.problems.randomElement().map(mapCF)
        } catch {
            print("CF fetch failed:", error)
            return nil
        }
    }

    private func fetchCodeChefProblem() async -> UnifiedProblem? {
        let page = Int.random(in: 1 ... 50)
        guard let url = URL(string: "https://www.codechef.com/api/list/problems?page=\(page)&limit=50") else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(CCProblemResponse.self, from: data)

            return decoded.data.randomElement().map {
                UnifiedProblem(
                    name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    platform: "CodeChef",
                    identifier: $0.code,
                    tags: ["Practice", "CodeChef"],
                    url: $0.problemUrl,
                    icon: "codechef"
                )
            }
        } catch {
            print("CC fetch failed:", error)
            return nil
        }
    }

    private func fetchLeetCodeProblem() async -> UnifiedProblem? {
        guard let url = URL(string: "https://leetcode.com/graphql") else { return nil }

        let body = """
        {"query":"query { activeDailyCodingChallengeQuestion { date link question { questionFrontendId title difficulty topicTags { name } } } }"}
        """

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(LCGraphQLResponse.self, from: data)

            let challenge = decoded.data.activeDailyCodingChallengeQuestion
            let tags = challenge.question.topicTags.map(\.name)

            return UnifiedProblem(
                name: challenge.question.title,
                platform: "LeetCode",
                identifier: "Daily \(challenge.date)",
                tags: Array(tags.prefix(3)),
                url: URL(string: "https://leetcode.com\(challenge.link)"),
                icon: "leetcode"
            )
        } catch {
            print("LC fetch failed:", error)
            return nil
        }
    }

    private func fetchAtCoderProblem() async -> UnifiedProblem? {
        if let cached = ProblemCache.shared.acProblems,
           let random = cached.randomElement()
        {
            return mapAC(random)
        }

        guard let url = URL(string: "https://kenkoooo.com/atcoder/resources/problems.json") else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode([ACProblem].self, from: data)

            ProblemCache.shared.acProblems = decoded
            return decoded.randomElement().map(mapAC)
        } catch {
            print("AC fetch failed:", error)
            return nil
        }
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
}
