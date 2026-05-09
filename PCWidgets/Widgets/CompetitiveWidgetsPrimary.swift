import SwiftUI
import WidgetKit

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
                    ),
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
            .systemSmall,
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
                    ),
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
            .systemSmall,
        ])
        .contentMarginsDisabled()
    }
}
