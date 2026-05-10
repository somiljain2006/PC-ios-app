//
//  ProgressViewScreen.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI

struct ProgressViewScreen: View {
    @StateObject private var vm = ProgressViewModel()
    @State private var showSetup = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                header
                GitHubCard(stats: vm.github)
                LeetCodeCard(stats: vm.leetcode)

                ForEach(vm.platforms) { platform in
                    PlatformGraphCard(stats: platform)
                }

                AtCoderCard(stats: vm.atcoder)
            }
            .padding()
        }
        .background(Color.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .applyNavigationBarTheme()
        .task {
            await vm.refresh()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ProgressBoard")
                        .font(.system(size: 30, weight: .black))
                    Text("Your coding analytics dashboard")
                        .font(.system(size: 14))
                        .foregroundColor(.onSurfaceVariant)
                }

                Spacer()

                Button { showSetup = true } label: {
                    Image(systemName: "link.badge.plus")
                        .font(.title3)
                        .foregroundColor(.primaryContainer)
                }
            }
            AddWidgetButton(type: .github)
        }
        .padding(.top, 12)
        .sheet(isPresented: $showSetup) {
            PlatformSetupView(vm: vm)
        }
    }
}

struct GitHubCard: View {
    let stats: GitHubStats

    private let rows = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Label("GitHub Activity", systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.onSurface)

                Text("\(stats.contributions.formatted()) Contributions this year")
                    .font(.system(size: 13))
                    .foregroundColor(.onSurfaceVariant)
            }

            githubHeatmap
            Divider()

            HStack {
                StatLabel(title: "Current Streak", value: "\(stats.currentStreak) Days", align: .leading)
                Spacer()
                StatLabel(title: "Max Streak", value: "\(stats.maxStreak) Days", align: .trailing)
            }

            ExportButton { GitHubCard(stats: stats) }
        }
        .padding()
        .background(Color.surfaceContainerLow)
        .cornerRadius(18)
    }

    private var githubHeatmap: some View {
        let chunks = stats.heatmap.chunked(into: rows)
        let cell: CGFloat = 12
        let weekGap: CGFloat = 4
        let columnCount = chunks.count
        let heatmapWidth = CGFloat(columnCount) * cell + CGFloat(Swift.max(0, columnCount - 1)) * weekGap
        let third = heatmapWidth / 3
        let axis = stats.heatmapMonthAxis

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text(axis.left)
                    .frame(width: third, alignment: .leading)
                Text(axis.center)
                    .frame(width: third, alignment: .center)
                Text(axis.right)
                    .frame(width: third, alignment: .trailing)
            }
            .frame(width: heatmapWidth)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)

            HStack(alignment: .top, spacing: weekGap) {
                ForEach(Array(chunks.enumerated()), id: \.offset) { _, week in
                    VStack(alignment: .leading, spacing: weekGap) {
                        ForEach(Array(week.enumerated()), id: \.offset) { _, level in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(level.color)
                                .frame(width: cell, height: cell)
                        }

                        if week.count < rows {
                            ForEach(0 ..< (rows - week.count), id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.clear)
                                    .frame(width: cell, height: cell)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LeetCodeCard: View {
    let stats: LeetCodeStats

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PlatformHeader(title: "LeetCode", icon: "chevron.left.forwardslash.chevron.right", badge: stats.badge, accent: .orange)

            HStack(spacing: 20) {
                RatingRing(rating: "\(stats.totalSolved)", subtitle: "/ \(stats.totalQuestions)", progress: Double(stats.totalSolved) / Double(stats.totalQuestions), accent: .orange)

                VStack(alignment: .leading, spacing: 14) {
                    ProgressRow(title: "Easy", progress: stats.easyProgress, color: .green, solved: stats.easySolved, total: stats.easyTotal)
                    ProgressRow(title: "Medium", progress: stats.mediumProgress, color: .yellow, solved: stats.mediumSolved, total: stats.mediumTotal)
                    ProgressRow(title: "Hard", progress: stats.hardProgress, color: .red, solved: stats.hardSolved, total: stats.hardTotal)
                }
            }

            Divider()

            HStack {
                StatLabel(title: "Current Streak", value: "\(stats.currentStreak) Days", align: .leading)
                Spacer()
                StatLabel(title: "Max Streak", value: "\(stats.maxStreak) Days", align: .trailing)
            }

            ExportButton { LeetCodeCard(stats: stats) }
        }
        .padding()
        .background(Color.surfaceContainerLow)
        .cornerRadius(18)
    }
}

struct PlatformGraphCard: View {
    let stats: RatedPlatformStats

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PlatformHeader(title: stats.title, icon: stats.icon, badge: stats.badge, accent: stats.accent)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rating").font(.caption).foregroundColor(.onSurfaceVariant)
                    Text("\(stats.rating)")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.onSurface)
                    Text("+\(stats.monthlyGain) this month")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(stats.accent)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Peak").font(.caption).foregroundColor(.onSurfaceVariant)
                    Text("\(stats.peak)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.onSurface)
                }
            }
            if let current = stats.currentStreak, let max = stats.maxStreak {
                HStack {
                    StatLabel(title: "Current Streak", value: "\(current) days", align: .leading)
                    Spacer()
                    StatLabel(title: "Max Streak", value: "\(max) days", align: .trailing)
                }
            }

            RoundedRectangle(cornerRadius: 14)
                .fill(Color.surfaceContainerLowest)
                .frame(height: 70)
                .overlay(GraphShape().stroke(stats.accent, lineWidth: 3).padding(12))

            ExportButton { PlatformGraphCard(stats: stats) }
        }
        .padding()
        .background(Color.surfaceContainerLow)
        .cornerRadius(18)
    }
}

struct AtCoderCard: View {
    let stats: AtCoderStats

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PlatformHeader(title: "AtCoder", icon: "waveform.path.ecg", badge: stats.badge, accent: stats.accentColor)

            Text("\(stats.rating)")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.onSurface)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Rating Goal")
                    Spacer()
                    Text(stats.progressLabel)
                }
                .font(.caption)
                .foregroundColor(.onSurfaceVariant)

                ProgressView(value: stats.progress).tint(stats.accentColor)
            }

            ExportButton { AtCoderCard(stats: stats) }
        }
        .padding()
        .background(Color.surfaceContainerLow)
        .cornerRadius(18)
    }
}

private extension View {
    @ViewBuilder
    func applyNavigationBarTheme() -> some View {
        if #available(iOS 16.0, *) {
            toolbarBackground(Color.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        } else {
            self
        }
    }
}
