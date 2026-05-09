//
//  ProgressComponents.swift
//  PC
//
//  Created by somil jain on 09/05/26.
//

import SwiftUI

struct PlatformHeader: View {
    let title: String
    let icon: String
    let badge: String
    let accent: Color

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.onSurface)
            Spacer()
            Text(badge)
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(accent.opacity(0.15))
                .foregroundColor(accent)
                .cornerRadius(20)
        }
    }
}

struct RatingRing: View {
    let rating: String
    let subtitle: String
    let progress: Double
    let accent: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.surfaceContainerHighest,
                    lineWidth: 8
                )
                .frame(width: 90, height: 90)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accent,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 90, height: 90)

            VStack(spacing: 3) {
                Text(rating)
                    .font(
                        .system(
                            size: 22,
                            weight: .black
                        )
                    )
                    .foregroundColor(.onSurface)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(subtitle)
                    .font(
                        .system(
                            size: 8,
                            weight: .medium
                        )
                    )
                    .foregroundColor(.onSurfaceVariant)
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
            .frame(width: 74)
        }
    }
}

struct StatLabel: View {
    let title: String
    let value: String
    let align: HorizontalAlignment

    var body: some View {
        VStack(alignment: align, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.onSurfaceVariant)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.onSurface)
        }
    }
}

struct ProgressRow: View {
    let title: String
    let progress: Double
    let color: Color
    let solved: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(solved)/\(total)")
            }
            .font(.caption)
            .foregroundColor(.onSurfaceVariant)

            ProgressView(value: progress)
                .tint(color)
        }
    }
}

struct GraphShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points: [(CGFloat, CGFloat)] = [
            (0, 0.8), (0.15, 0.6), (0.3, 0.7),
            (0.45, 0.45), (0.6, 0.5), (0.75, 0.25), (1.0, 0.1),
        ]
        path.move(to: CGPoint(x: rect.width * points[0].0, y: rect.height * points[0].1))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: rect.width * point.0, y: rect.height * point.1))
        }
        return path
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
