//
//  WidgetData.swift
//  PC
//
//  Created by somil jain on 09/05/26.
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
        self.easySolved = easySolved
        self.mediumSolved = mediumSolved
        self.hardSolved = hardSolved
    }
}
