//
//  Color+Theme.swift
//  PC
//
//  Created by somil jain on 12/04/26.
//

import SwiftUI

extension Color {
    static let background = Color(hex: "#18101f")
    static let surface = Color(hex: "#18101f")
    static let surfaceContainer = Color(hex: "#251c2c")
    static let surfaceContainerLow = Color(hex: "#211828")
    static let surfaceContainerHigh = Color(hex: "#302637")

    static let onSurface = Color(hex: "#edddf4")
    static let onSurfaceVariant = Color(hex: "#e4beba")

    static let primary = Color(hex: "#ffb3ae")
    static let primaryContainer = Color(hex: "#ff5352")
    static let onPrimaryContainer = Color(hex: "#5c0008")

    static let secondary = Color(hex: "#e4b5ff")
    static let secondaryContainer = Color(hex: "#8e03d5")

    static let outlineVariant = Color(hex: "#5b403e")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue: UInt64
        (red, green, blue) = ((int >> 16) & 0xFF,
                              (int >> 8) & 0xFF,
                              int & 0xFF)

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}
