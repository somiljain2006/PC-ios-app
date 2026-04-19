//
//  AchievementCard.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import SwiftUI

struct AchievementCard: View {
    var icon: String
    var title: String
    var subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color.onSurface)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.onSurfaceVariant)
                    .italic()
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceContainer)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.outlineVariant.opacity(0.10), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
