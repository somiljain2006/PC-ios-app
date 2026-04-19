//
//  MemberGroupCard.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import SwiftUI

struct MemberGroupCard: View {
    var year: String
    var count: Int
    var imageName: String

    var body: some View {
        VStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)

            HStack {
                Text(year)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.onSurface)

                Spacer()

                Text("\(count) Members")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.primaryContainer)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primaryContainer.opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.surfaceContainerLow)
        .cornerRadius(12)
    }
}
