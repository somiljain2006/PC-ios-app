//
//  PinnedChallengeManager.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Foundation

class PinnedChallengeManager {
    private static let key = "pinned_challenge"

    static func save(_ problem: UnifiedProblem) {
        if let data = try? JSONEncoder().encode(problem) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> UnifiedProblem? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let problem = try? JSONDecoder().decode(UnifiedProblem.self, from: data)
        else { return nil }

        return problem
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
