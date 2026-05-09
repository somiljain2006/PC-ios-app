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
        Color(red: 0.35, green: 0.95, blue: 0.38)
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
                    )
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
    func placeholder(in context: Context) -> PCWidgetsEntry {
        PCWidgetsEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PCWidgetsEntry) -> Void) {
        completion(PCWidgetsEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PCWidgetsEntry>) -> Void) {
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
            .systemMedium
        ])
        .contentMarginsDisabled()
    }
}

struct LeetCodeWidgetEntryView: View {

    private let defaults = UserDefaults(
        suiteName: "group.com.pc.app"
    )

    private var leetcodeData: WidgetPlatformData? {

        guard
            let raw = defaults?.data(forKey: "leetcode_widget"),
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

    private var easySolved: Int {
        leetcodeData?.easySolved ?? 0
    }

    private var mediumSolved: Int {
        leetcodeData?.mediumSolved ?? 0
    }

    private var hardSolved: Int {
        leetcodeData?.hardSolved ?? 0
    }

    private var totalByDifficulty: Int {
        max(easySolved + mediumSolved + hardSolved, 1)
    }

    private var easyFraction: CGFloat {
        CGFloat(easySolved) / CGFloat(totalByDifficulty)
    }

    private var mediumFraction: CGFloat {
        CGFloat(mediumSolved) / CGFloat(totalByDifficulty)
    }

    private var hardFraction: CGFloat {
        CGFloat(hardSolved) / CGFloat(totalByDifficulty)
    }

    var body: some View {

        ZStack {

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
                    )
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {

                HStack {

                    Spacer()

                    HStack(spacing: 6) {

                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.orange)
                            .frame(width: 15, height: 15)

                        Text("LeetCode")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    Spacer()
                }
                .offset(x: -8)

                Spacer()

                HStack {
                    Spacer()

                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .stroke(
                                Color.white.opacity(0.12),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(180))

                        Circle()
                            .trim(from: 0, to: 0.5 * easyFraction)
                            .stroke(
                                Color.green,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(180))

                        Circle()
                            .trim(from: 0.5 * easyFraction, to: 0.5 * (easyFraction + mediumFraction))
                            .stroke(
                                Color.yellow,
                                style: StrokeStyle(lineWidth: 10, lineCap: .butt)
                            )
                            .rotationEffect(.degrees(180))

                        Circle()
                            .trim(from: 0.5 * (easyFraction + mediumFraction), to: 0.5 * (easyFraction + mediumFraction + hardFraction))
                            .stroke(
                                Color.red,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(180))

                        VStack(spacing: 4) {
                            Text(leetcodeData?.primaryValue ?? "0")
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(.white)

                            Text("Solved")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(width: 118, height: 118)

                    Spacer()
                }

                Spacer()
            }
            .padding(14)
        }
        .containerBackground(
            for: .widget
        ) {
            Color.clear
        }
        .padding(.top, 35)
    }

}

struct LeetCodeWidget: Widget {

    private let kind = "LeetCodeWidget"

    var body: some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider: PCWidgetsTimelineProvider()
        ) { _ in

            LeetCodeWidgetEntryView()
        }
        .configurationDisplayName("LeetCode Stats")
        .description("Shows your LeetCode progress.")
        .supportedFamilies([
            .systemSmall
        ])
    }
}

struct CodeforcesWidgetEntryView: View {

    private let defaults = UserDefaults(
        suiteName: "group.com.pc.app"
    )

    private var codeforcesData: WidgetPlatformData? {

        guard
            let raw = defaults?.data(forKey: "codeforces_widget"),
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

    var body: some View {

        ZStack {

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
                    )
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)

                    Text("Codeforces")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Text("RATING")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.65))

                    Spacer(minLength: 0)

                    Text(codeforcesData?.secondaryValue ?? "Newbie")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.78))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Text(codeforcesData?.primaryValue ?? "0")
                    .font(.system(size: 44, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 4) {
                    Image(systemName: (codeforcesData?.monthlyGain ?? 0) >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10, weight: .bold))

                    Text("\((codeforcesData?.monthlyGain ?? 0) >= 0 ? "+" : "")\(codeforcesData?.monthlyGain ?? 0) this month")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .containerBackground(
            for: .widget
        ) {
            Color.clear
        }
    }
}

struct CodeforcesWidget: Widget {

    private let kind = "CodeforcesWidget"

    var body: some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider: PCWidgetsTimelineProvider()
        ) { _ in

            CodeforcesWidgetEntryView()
        }
        .configurationDisplayName("Codeforces Rating")
        .description("Shows your Codeforces stats.")
        .supportedFamilies([
            .systemSmall
        ])
        .contentMarginsDisabled()
    }
}
struct CodeChefWidgetEntryView: View {

    private let defaults = UserDefaults(
        suiteName: "group.com.pc.app"
    )

    private var codechefData: WidgetPlatformData? {

        guard
            let raw = defaults?.data(forKey: "codechef_widget"),
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

    var body: some View {

        ZStack {

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
                    )
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.2))

                    Text("CodeChef")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Text("RATING")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.65))

                    Spacer(minLength: 0)

                    Text(codechefData?.secondaryValue ?? "1-Star")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.78))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Text(codechefData?.primaryValue ?? "0")
                    .font(.system(size: 44, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 4) {
                    Image(systemName: (codechefData?.monthlyGain ?? 0) >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10, weight: .bold))

                    Text("\((codechefData?.monthlyGain ?? 0) >= 0 ? "+" : "")\(codechefData?.monthlyGain ?? 0) this month")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .containerBackground(
            for: .widget
        ) {
            Color.clear
        }
    }
}

struct CodeChefWidget: Widget {

    private let kind = "CodeChefWidget"

    var body: some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider: PCWidgetsTimelineProvider()
        ) { _ in

            CodeChefWidgetEntryView()
        }
        .configurationDisplayName("CodeChef Rating")
        .description("Shows your CodeChef stats.")
        .supportedFamilies([
            .systemSmall
        ])
        .contentMarginsDisabled()
    }
}

struct AtCoderWidgetEntryView: View {

    private let defaults = UserDefaults(
        suiteName: "group.com.pc.app"
    )

    private let ratingGoal = 1600

    private var atcoderData: WidgetPlatformData? {
        guard
            let raw = defaults?.data(forKey: "atcoder_widget"),
            let decoded = try? JSONDecoder().decode(WidgetPlatformData.self, from: raw)
        else {
            return nil
        }

        return decoded
    }

    private var rating: Int {
        Int(atcoderData?.primaryValue ?? "0") ?? 0
    }

    private var progress: Double {
        let safeGoal = max(ratingGoal, 1)
        return min(max(Double(rating) / Double(safeGoal), 0), 1)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.05, blue: 0.16),
                    Color(red: 0.09, green: 0.04, blue: 0.13)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.cyan)

                        Text("AtCoder")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }

                    Spacer(minLength: 0)

                    Text(atcoderData?.secondaryValue ?? "Cyan")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Text("RATING")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.65))

                Text("\(rating)")
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack {
                    Text("\(rating)/\(ratingGoal)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.75))

                    Spacer(minLength: 0)
                }

                ProgressView(value: progress)
                    .tint(.cyan)
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct AtCoderWidget: Widget {
    private let kind = "AtCoderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PCWidgetsTimelineProvider()
        ) { _ in
            AtCoderWidgetEntryView()
        }
        .configurationDisplayName("AtCoder Rating")
        .description("Shows your AtCoder rating progress.")
        .supportedFamilies([
            .systemSmall
        ])
        .contentMarginsDisabled()
    }
}
