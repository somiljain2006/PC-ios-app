//
//  WidgetData.swift
//  PCWidgets
//
//  Created by Codex on 08/05/26.
//

import Foundation

struct WidgetPlatformData: Codable {
    let title: String
    let primaryValue: String
    let secondaryValue: String
    let accent: String

    let currentStreak: Int?
    let maxStreak: Int?

    let peakRating: Int?

    let monthlyGain: Int?

    let heatmapLevels: [Int]?

    let easySolved: Int?
    let mediumSolved: Int?
    let hardSolved: Int?

    let githubMonthLeft: String?
    let githubMonthCenter: String?
    let githubMonthRight: String?

    let heatmapLevelsLarge: [Int]?
    let githubLargeMonths: [String]?

    init(
        title: String,
        primaryValue: String,
        secondaryValue: String,
        accent: String,
        currentStreak: Int?,
        maxStreak: Int?,

        peakRating: Int? = nil,
        monthlyGain: Int? = nil,
        heatmapLevels: [Int]? = nil,

        githubMonthLeft: String? = nil,
        githubMonthCenter: String? = nil,
        githubMonthRight: String? = nil,

        heatmapLevelsLarge: [Int]? = nil,
        githubLargeMonths: [String]? = nil,

        easySolved: Int? = nil,
        mediumSolved: Int? = nil,
        hardSolved: Int? = nil
    ) {
        self.title = title
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.accent = accent

        self.currentStreak = currentStreak
        self.maxStreak = maxStreak

        self.peakRating = peakRating
        self.monthlyGain = monthlyGain
        self.heatmapLevels = heatmapLevels

        self.githubMonthLeft = githubMonthLeft
        self.githubMonthCenter = githubMonthCenter
        self.githubMonthRight = githubMonthRight

        self.heatmapLevelsLarge = heatmapLevelsLarge
        self.githubLargeMonths = githubLargeMonths

        self.easySolved = easySolved
        self.mediumSolved = mediumSolved
        self.hardSolved = hardSolved
    }
}
