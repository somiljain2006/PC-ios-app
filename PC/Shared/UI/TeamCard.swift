//
//  TeamCard.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import SwiftUI

struct TeamCard: View {
    var name: String
    var role: String
    var desc: String
    var imageName: String

    var body: some View {
        VStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .cornerRadius(12)
                .grayscale(1)

            Text(name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.onSurface)
                .multilineTextAlignment(.center)

            Text(role)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.primary)
                .tracking(1)
                .multilineTextAlignment(.center)

            Text(desc)
                .font(.system(size: 12))
                .foregroundColor(Color.onSurfaceVariant)
                .lineSpacing(3)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(Color.surfaceContainerLow)
        .cornerRadius(12)
    }
}
