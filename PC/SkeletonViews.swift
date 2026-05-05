//
//  SkeletonViews.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import SwiftUI

struct SkeletonShimmer: ViewModifier {
    @State private var move = false

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.25),
                        Color.white.opacity(0.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: move ? 300 : -300)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    move = true
                }
            }
    }
}

struct SkeletonBlock: View {
    var width: CGFloat?
    var height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.surfaceContainerHigh)
            .frame(width: width, height: height)
            .modifier(SkeletonShimmer())
    }
}

struct DailyChallengeSkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonBlock(width: 180, height: 18)
                    SkeletonBlock(width: 140, height: 12)

                    HStack(spacing: 6) {
                        SkeletonBlock(width: 50, height: 18)
                        SkeletonBlock(width: 60, height: 18)
                        SkeletonBlock(width: 40, height: 18)
                    }
                    .padding(.top, 4)
                }

                Spacer()

                Circle()
                    .fill(Color.surfaceContainerHigh)
                    .frame(width: 40, height: 40)
                    .modifier(SkeletonShimmer())
            }

            Spacer()

            SkeletonBlock(height: 40)
        }
        .padding(16)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(16)
    }
}
