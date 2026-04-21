//
//  ContestService.swift
//  PC
//
//  Created by somil jain on 21/04/26.
//

import Combine
import Foundation

class ContestService: ObservableObject {
    @Published var allUpcomingContests: [AppContest] = []
    @Published var isLoading: Bool = false

    func fetchAllContests() async {
        await MainActor.run { self.isLoading = true }

        async let leetcode = fetchLeetCodeContests()
        async let codechef = fetchCodeChefContests()
        async let codeforces = fetchCodeforcesContests()
        async let atcoder = fetchAtCoderContests()

        let combined = await (leetcode + codechef + codeforces + atcoder).sorted { $0.startTime < $1.startTime }

        await MainActor.run {
            self.allUpcomingContests = combined
            self.isLoading = false
        }
    }

    private func fetchLeetCodeContests() async -> [AppContest] {
        guard let url = URL(string: "https://leetcode.com/graphql") else { return [] }

        let query = """
        {
          "query": "query { topTwoContests { title startTime } }"
        }
        """

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = query.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(LeetCodeResponse.self, from: data)

            return decodedResponse.data.topTwoContests.map {
                AppContest(
                    title: $0.title,
                    platform: "LeetCode",
                    icon: "leetcode",
                    startTime: Date(timeIntervalSince1970: TimeInterval($0.startTime))
                )
            }
        } catch {
            return []
        }
    }

    private func fetchCodeChefContests() async -> [AppContest] {
        guard let url = URL(string: "https://www.codechef.com/api/list/contests/all?sort_by=START&sorting_order=asc&offset=0&mode=all") else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(CodeChefResponse.self, from: data)

            let formatter = ISO8601DateFormatter()

            return decodedResponse.futureContests.compactMap { contest in
                guard let date = formatter.date(from: contest.contestStartDateIso) else { return nil }
                return AppContest(
                    title: contest.contestName,
                    platform: "CodeChef",
                    icon: "codechef",
                    startTime: date
                )
            }
        } catch {
            return []
        }
    }

    private func fetchCodeforcesContests() async -> [AppContest] {
        guard let url = URL(string: "https://codeforces.com/api/contest.list") else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(CodeforcesResponse.self, from: data)

            return decodedResponse.result
                .filter { $0.phase == "BEFORE" }
                .compactMap { contest in
                    guard let startTime = contest.startTimeSeconds else { return nil }
                    return AppContest(
                        title: contest.name,
                        platform: "Codeforces",
                        icon: "codeforces",
                        startTime: Date(timeIntervalSince1970: TimeInterval(startTime))
                    )
                }
        } catch {
            return []
        }
    }

    private func fetchAtCoderContests() async -> [AppContest] {
        guard let url = URL(string: "https://atcoder.jp/contests/") else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let htmlString = String(data: data, encoding: .utf8) else { return [] }

            let pattern = "<time class='fixtime fixtime-full'>([^<]+)</time>.*?<a href=\"/contests/[^\"]+\">([^<]+)</a>"
            let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])

            let nsString = htmlString as NSString
            let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: nsString.length))

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")

            var contests: [AppContest] = []
            let currentDate = Date()

            for match in matches where match.numberOfRanges == 3 {
                let dateString = nsString.substring(with: match.range(at: 1))
                let titleString = nsString.substring(with: match.range(at: 2))

                if let startDate = formatter.date(from: dateString), startDate > currentDate {
                    let cleanTitle = titleString.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "&#39;", with: "'")
                        .replacingOccurrences(of: "&amp;", with: "&")

                    let isTargetContest = cleanTitle.contains("Beginner Contest") ||
                        cleanTitle.contains("Regular Contest") ||
                        cleanTitle.contains("Grand Contest")

                    if isTargetContest {
                        contests.append(AppContest(
                            title: cleanTitle,
                            platform: "AtCoder",
                            icon: "atcoder",
                            startTime: startDate
                        ))
                    }
                }
            }
            return contests
        } catch {
            return []
        }
    }
}
