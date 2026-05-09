import SwiftUI
import WidgetKit

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
                    ),
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
            .systemSmall,
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
                    Color(red: 0.09, green: 0.04, blue: 0.13),
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
            .systemSmall,
        ])
        .contentMarginsDisabled()
    }
}
