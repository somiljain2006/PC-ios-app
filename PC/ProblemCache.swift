//
//  ProblemCache.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Foundation

class ProblemCache {
    static let shared = ProblemCache()

    var cfProblems: [CFProblem]?
    var acProblems: [ACProblem]?

    private init() {}
}
