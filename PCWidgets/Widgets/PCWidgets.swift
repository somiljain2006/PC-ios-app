//
//  PCWidgets.swift
//  PCWidgets
//
//  Created by somil jain on 09/05/26.
//

import SwiftUI
import WidgetKit

struct PCWidgetsEntryView: View {
    private let columns = Array(
        repeating: GridItem(.fixed(11), spacing: 4),
        count: 14
    )

    private let levels: [Color] = [
        Color(red: 0.20, green: 0.17, blue: 0.25),
        Color(red: 0.18, green: 0.45, blue: 0.22),
        Color(red: 0.24, green: 0.70, blue: 0.28),
        Color(red: 0.35, green: 0.95, blue: 0.38),
    ]

    private var heatmap: [Int] {
        let stored = githubData?.heatmapLevels ?? []

        if stored.count >= 98 {
            return Array(stored.suffix(98))
        }

        return Array(repeating: 0, count: 98 - stored.count) + stored
    }

    private var monthLabels: [String] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM"

        let now = Date()
        return (-3 ... 0).compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: offset, to: now) else {
                return nil
            }
            return formatter.string(from: date).uppercased()
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(
                        red: 0.12,
                        green: 0.05,
                        blue: 0.16
                    ),

                    Color(
                        red: 0.09,
                        green: 0.04,
                        blue: 0.13
                    ),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.green)
                            .frame(width: 16, height: 16)

                        Text("GitHub Activity")
                            .font(
                                .system(
                                    size: 15,
                                    weight: .black
                                )
                            )
                            .foregroundColor(.white)
                    }

                    Text(
                        "\(githubData?.primaryValue ?? "0") Contributions this year"
                    )
                    .font(.system(size: 10))
                    .foregroundColor(
                        .white.opacity(0.75)
                    )
                }

                HStack {
                    ForEach(Array(monthLabels.enumerated()), id: \.offset) { index, month in
                        Text(month)
                        if index < monthLabels.count - 1 {
                            Spacer()
                        }
                    }
                }
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    .white.opacity(0.65)
                )

                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: 2
                ) {
                    ForEach(
                        heatmap.indices,
                        id: \.self
                    ) { index in
                        RoundedRectangle(
                            cornerRadius: 3
                        )
                        .fill(
                            levels[
                                heatmap[index]
                            ]
                        )
                        .frame(
                            width: 10,
                            height: 10
                        )
                    }
                }
                Spacer(minLength: 4)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 10)
            .padding(.top, 16)
        }
        .containerBackground(
            for: .widget
        ) {
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
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct PCWidgets: Widget {
    private let kind = "PCWidgets"

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
