//
//  ProgressViewModel.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import Combine
import SwiftUI
import WidgetKit

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published private(set) var github = GitHubStats.empty()
    @Published private(set) var leetcode = LeetCodeStats.empty
    @Published private(set) var platforms: [RatedPlatformStats] = .empty
    @Published private(set) var atcoder = AtCoderStats.empty

    struct UserHandles: Codable {
        var github: String?
        var codeforces: String?
        var codechef: String?
        var atcoder: String?
        var leetcode: String?
    }

    private static let handlesKey = "progress_user_handles"
    @Published private(set) var handles: UserHandles

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.handlesKey),
           let loaded = try? JSONDecoder().decode(UserHandles.self, from: data)
        {
            handles = loaded
        } else {
            handles = UserHandles()
        }
    }

    private func saveHandles() {
        if let data = try? JSONEncoder().encode(handles) {
            UserDefaults.standard.set(data, forKey: Self.handlesKey)
        }
    }

    func setGitHubUsername(_ username: String, refreshAfter: Bool = true) {
        handles.github = username; saveHandles()
        if refreshAfter { Task { await refresh() } }
    }

    func setCodeforcesHandle(_ handle: String, refreshAfter: Bool = true) {
        handles.codeforces = handle; saveHandles()
        if refreshAfter { Task { await refresh() } }
    }

    func setCodeChefHandle(_ handle: String, refreshAfter: Bool = true) {
        handles.codechef = handle; saveHandles()
        if refreshAfter { Task { await refresh() } }
    }

    func setAtCoderHandle(_ handle: String, refreshAfter: Bool = true) {
        handles.atcoder = handle; saveHandles()
        if refreshAfter { Task { await refresh() } }
    }

    func setLeetCodeUsername(_ username: String, refreshAfter: Bool = true) {
        handles.leetcode = username; saveHandles()
        if refreshAfter { Task { await refresh() } }
    }

    var allHandlesConfigured: Bool {
        let github = !(UserDefaults.standard.string(forKey: "github_username") ?? "").isEmpty
        let lc = !(handles.leetcode ?? "").isEmpty
        let cf = !(handles.codeforces ?? "").isEmpty
        return github && lc && cf
    }

    func refresh() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchGitHub() }
            group.addTask { await self.fetchLeetCode() }
            group.addTask { await self.fetchCodeforces() }
            group.addTask { await self.fetchCodeChef() }
            group.addTask { await self.fetchAtCoder() }
        }
    }

    private let sharedDefaults = UserDefaults(suiteName: "group.com.pc.app")

    func saveWidgetData(key: String, data: WidgetPlatformData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        sharedDefaults?.set(encoded, forKey: key)
    }

    func updateGitHub(_ stats: GitHubStats) {
        github = stats
    }

    func updateAtCoder(_ stats: AtCoderStats) {
        atcoder = stats
    }

    func updateLeetCode(_ stats: LeetCodeStats) {
        leetcode = stats
    }

    func upsertPlatform(_ platform: RatedPlatformStats, insertAtStart: Bool = false) {
        platforms.removeAll { $0.title == platform.title }
        if insertAtStart {
            platforms.insert(platform, at: 0)
        } else {
            platforms.append(platform)
        }
    }
}
