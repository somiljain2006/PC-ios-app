//
//  PCWidgets.swift
//  PCWidgets
//
//  Created by somil jain on 09/05/26.
//

import SwiftUI
import WidgetKit

struct PCWidgetsEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    private let standardContributionDayCount = 105
    private let rowsPerWeek = 7

    private var useExtendedLargeHeatmap: Bool {
        !(githubData?.heatmapLevelsLarge ?? []).isEmpty
    }

    private var activeContributionDayCount: Int {
        if useExtendedLargeHeatmap, let count = githubData?.heatmapLevelsLarge?.count, count > 0 {
            return count
        }
        return standardContributionDayCount
    }

    private var heatmapLevels: [Int] {
        let raw: [Int]? = useExtendedLargeHeatmap
            ? githubData?.heatmapLevelsLarge
            : githubData?.heatmapLevels
        return normalizedHeatmapLevels(raw, length: activeContributionDayCount)
    }

    private var weekColumns: [[Int]] {
        heatmapLevels.chunked(into: rowsPerWeek)
    }

    private var fourMonthRibbon: [String] {
        guard let months = githubData?.githubLargeFourMonths else {
            return ["", "", "", ""]
        }
        if months.count >= 4 {
            return Array(months.prefix(4))
        }
        return months + Array(repeating: "", count: 4 - months.count)
    }

    private var monthLeft: String {
        githubData?.githubMonthLeft ?? ""
    }

    private var monthCenter: String {
        githubData?.githubMonthCenter ?? ""
    }

    private var monthRight: String {
        githubData?.githubMonthRight ?? ""
    }

    private struct LayoutMetrics {
        let cell: CGFloat
        let weekGap: CGFloat
        let padLeading: CGFloat
        let padTrailing: CGFloat
        let padV: CGFloat
        let titleFont: CGFloat
        let iconFont: CGFloat
        let headerSpacing: CGFloat
    }

    private var layout: LayoutMetrics {
        LayoutMetrics(
            cell: 8,
            weekGap: 2,
            padLeading: 14,
            padTrailing: 14,
            padV: 10,
            titleFont: 14,
            iconFont: 14,
            headerSpacing: 8
        )
    }

    private func normalizedHeatmapLevels(_ stored: [Int]?, length: Int) -> [Int] {
        let stored = stored ?? []
        if stored.count >= length {
            return Array(stored.suffix(length))
        }
        return Array(repeating: 0, count: length - stored.count) + stored
    }

    private func cellFill(for level: Int) -> Color {
        switch level {
        case 0:
            Color(red: 59 / 255, green: 49 / 255, blue: 66 / 255)
        case 1:
            Color.green.opacity(0.3)
        case 2:
            Color.green.opacity(0.6)
        default:
            Color.green
        }
    }

    private func alignmentForFourMonth(_ index: Int) -> Alignment {
        switch index {
        case 0: .leading
        case 3: .trailing
        default: .center
        }
    }

    var body: some View {
        let metrics = layout
        let columnCount = weekColumns.count
        let heatmapWidth = CGFloat(columnCount) * metrics.cell + CGFloat(Swift.max(0, columnCount - 1)) * metrics.weekGap
        let third = heatmapWidth / 3
        let quarter = heatmapWidth / 4

        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.05, blue: 0.16),
                    Color(red: 0.09, green: 0.04, blue: 0.13),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: metrics.headerSpacing) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: metrics.iconFont, weight: .bold))
                        .foregroundColor(.green)
                        .frame(width: metrics.iconFont + 1, height: metrics.iconFont + 1)

                    Text("GitHub Activity")
                        .font(.system(size: metrics.titleFont, weight: .black))
                        .foregroundColor(.white)
                }

                Text("\(githubData?.primaryValue ?? "0") Contributions this year")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.75))

                VStack(alignment: .leading, spacing: 6) {
                    if useExtendedLargeHeatmap {
                        HStack(spacing: 0) {
                            ForEach(0 ..< 4, id: \.self) { index in
                                Text(fourMonthRibbon[index])
                                    .frame(width: quarter, alignment: alignmentForFourMonth(index))
                            }
                        }
                        .frame(width: heatmapWidth)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    } else {
                        HStack(spacing: 0) {
                            Text(monthLeft)
                                .frame(width: third, alignment: .leading)
                            Text(monthCenter)
                                .frame(width: third, alignment: .center)
                            Text(monthRight)
                                .frame(width: third, alignment: .trailing)
                        }
                        .frame(width: heatmapWidth)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    }

                    HStack(alignment: .top, spacing: metrics.weekGap) {
                        ForEach(Array(weekColumns.enumerated()), id: \.offset) { _, week in
                            VStack(alignment: .leading, spacing: metrics.weekGap) {
                                ForEach(Array(week.enumerated()), id: \.offset) { _, level in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(cellFill(for: level))
                                        .frame(width: metrics.cell, height: metrics.cell)
                                }
                                if week.count < rowsPerWeek {
                                    ForEach(0 ..< (rowsPerWeek - week.count), id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.clear)
                                            .frame(width: metrics.cell, height: metrics.cell)
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.leading, metrics.padLeading)
            .padding(.trailing, metrics.padTrailing)
            .padding(.vertical, metrics.padV)
            .padding(.top, widgetFamily == .systemLarge ? 4 : 2)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private let defaults = UserDefaults(
        suiteName: "group.com.pc.app"
    )

    private var githubData: WidgetPlatformData? {
        guard
            let raw = defaults?.data(forKey: "github_widget"),
            let decoded = try? JSONDecoder()
            .decode(
                WidgetPlatformData.self,
                from: raw
            )
        else {
            return nil
        }

        return decoded
    }
}

struct PCWidgetsEntry: TimelineEntry {
    let date: Date
}

struct PCWidgetsTimelineProvider: TimelineProvider {
    func placeholder(in _: Context) -> PCWidgetsEntry {
        PCWidgetsEntry(date: Date())
    }

    func getSnapshot(in _: Context, completion: @escaping (PCWidgetsEntry) -> Void) {
        completion(PCWidgetsEntry(date: Date()))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<PCWidgetsEntry>) -> Void) {
        let entry = PCWidgetsEntry(date: Date())
        let next = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date().addingTimeInterval(14400)
        let timeline = Timeline(entries: [entry], policy: .after(next))
        completion(timeline)
    }
}

struct PCWidgets: Widget {
    private let kind = "GitHubActivityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PCWidgetsTimelineProvider()) { _ in
            PCWidgetsEntryView()
        }
        .configurationDisplayName("GitHub Activity")
        .description("Shows your contribution heatmap.")
        .supportedFamilies([
            .systemMedium,
        ])
        .contentMarginsDisabled()
    }
}

private extension [Int] {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
