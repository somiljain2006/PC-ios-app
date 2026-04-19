//
//  GalleryItem.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import SwiftUI

struct GalleryItem: View {
    var imageName: String
    var caption: String
    var animation: Namespace.ID
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if !isSelected {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180, alignment: .top)
                        .clipped()
                        .matchedGeometryEffect(id: imageName, in: animation)
                }

                LinearGradient(
                    colors: [Color.background.opacity(0.0), Color.background.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .cornerRadius(12)

            Text(caption)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.onSurfaceVariant)
                .tracking(1)
                .multilineTextAlignment(.center)
        }
    }
}
