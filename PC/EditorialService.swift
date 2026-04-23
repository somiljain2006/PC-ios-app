//
//  EditorialService.swift
//  PC
//
//  Created by somil jain on 23/04/26.
//

import Combine
import Foundation

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

    func fetchEditorialDetail(slug: String) async throws -> PCEditorialDetail {
        let urlString = "https://editorial.monu14.me/api/editorials/\(slug)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200 ... 299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(PCEditorialDetail.self, from: data)
    }
}
