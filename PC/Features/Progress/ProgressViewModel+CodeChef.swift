//
//  ProgressViewModel+CodeChef.swift
//  PC
//
//  Created by somil jain on 09/05/26.
//

import Combine
import SwiftUI
import WidgetKit

extension ProgressViewModel {
    func fetchCodeChef() async {
        guard let handle = handles.codechef?.trimmingCharacters(in: .whitespacesAndNewlines),
              !handle.isEmpty, let url = URL(string: "https://www.codechef.com/users/\(handle)") else { return }

        do {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            request.setValue("text/html,application/xhtml+xml", forHTTPHeaderField: "Accept")
            request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  let html = String(data: data, encoding: .utf8)
            else { print("CodeChef: bad HTTP response"); return }

            guard let parsed = parseCodeChefNextData(html) else { print("CodeChef: all parse strategies failed"); return }

            let dynamicGain = extractCodeChefMonthlyGain(from: html, currentRating: parsed.currentRating)

            let cc = RatedPlatformStats(
                title: "CodeChef", icon: "terminal", accent: .orange, badge: parsed.stars,
                rating: parsed.currentRating, peak: parsed.highestRating, monthlyGain: dynamicGain,
                currentStreak: nil, maxStreak: nil
            )

            upsertPlatform(cc)

            let widgetData = WidgetPlatformData(
                title: "CodeChef", primaryValue: "\(cc.rating)", secondaryValue: cc.badge, accent: "orange",
                currentStreak: cc.currentStreak, maxStreak: cc.maxStreak, peakRating: cc.peak, monthlyGain: cc.monthlyGain
            )
            saveWidgetData(key: "codechef_widget", data: widgetData)
            WidgetCenter.shared.reloadAllTimelines()

        } catch is CancellationError {
        } catch { print("CodeChef fetch failed:", error) }
    }

    private func parseCodeChefNextData(_ html: String) -> CodeChefParsedData? {
        func extractNumber(pattern: String) -> Int? {
            guard let range = html.range(of: pattern, options: .regularExpression) else { return nil }
            let matchString = String(html[range])
            let digits = matchString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(digits)
        }

        var current = extractNumber(pattern: #"(?i)"currentRating"\s*:\s*\d+"#)
        var peak = extractNumber(pattern: #"(?i)"highestRating"\s*:\s*\d+"#)

        if current == nil { current = extractNumber(pattern: #"class="rating-number"[^>]*>\s*\d+"#) }
        if peak == nil { peak = extractNumber(pattern: #"(?i)Highest Rating[^0-9]*\d+"#) }

        guard let currentRating = current else { return nil }

        return CodeChefParsedData(
            currentRating: currentRating,
            highestRating: peak ?? currentRating,
            stars: starsForRating(currentRating)
        )
    }

    private func extractCodeChefMonthlyGain(from html: String, currentRating: Int) -> Int {
        if let history = extractAllRatingArray(from: html) { return calculateGain(from: history, currentRating: currentRating) }
        if let history = extractFromNextData(html) { return calculateGain(from: history, currentRating: currentRating) }
        return 0
    }

    private func extractAllRatingArray(from html: String) -> [[String: Any]]? {
        let markers = ["var all_rating", "all_rating"]
        for marker in markers {
            guard let markerRange = html.range(of: marker),
                  let openRange = html.range(of: "[", range: markerRange.upperBound ..< html.endIndex),
                  let end = findClosingBracket(in: html, startingAt: openRange.lowerBound)
            else { continue }

            let jsonString = String(html[openRange.lowerBound ... end])
            guard let jsonData = jsonString.data(using: .utf8),
                  let array = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                  let first = array.first, first["rating"] != nil
            else { continue }
            return array
        }
        return nil
    }

    private func findClosingBracket(in text: String, startingAt startIndex: String.Index) -> String.Index? {
        var depth = 0
        for idx in text[startIndex...].indices {
            let char = text[idx]
            if char == "[" { depth += 1 } else if char == "]" {
                depth -= 1
                if depth == 0 { return idx }
            }
        }
        return nil
    }

    private func extractFromNextData(_ html: String) -> [[String: Any]]? {
        let markers = [#"<script id="__NEXT_DATA__" type="application/json">"#, #"<script type="application/json" id="__NEXT_DATA__">"#, "__NEXT_DATA__"]
        var jsonData: Data?
        for marker in markers {
            guard let tagRange = html.range(of: marker),
                  let gtRange = html.range(of: ">", range: tagRange),
                  let closeTag = html.range(of: "</script>", range: gtRange.upperBound ..< html.endIndex),
                  let data = html[gtRange.upperBound ..< closeTag.lowerBound].data(using: .utf8)
            else { continue }
            jsonData = data
            break
        }
        guard let data = jsonData, let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return findRatingArray(in: root)
    }

    private func calculateGain(from history: [[String: Any]], currentRating: Int) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        guard let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) else { return 0 }

        for entry in history.reversed() {
            guard let dateStr = entry["end_date"] as? String, let date = formatter.date(from: dateStr) else { continue }
            let baseline: Int?
            if let ratingInt = entry["rating"] as? Int {
                baseline = ratingInt
            } else if let ratingString = entry["rating"] as? String {
                baseline = Int(ratingString) ?? 0
            } else {
                continue
            }
            guard let base = baseline else { continue }
            if date < monthAgo { return currentRating - base }
        }
        if let first = history.first {
            if let ratingValue = first["rating"] as? Int { return currentRating - ratingValue }
            if let str = first["rating"] as? String, let val = Int(str) { return currentRating - val }
        }
        return 0
    }

    private func findRatingArray(in value: Any) -> [[String: Any]]? {
        if let array = value as? [[String: Any]], let first = array.first, first["rating"] != nil, first["end_date"] != nil { return array }
        if let dict = value as? [String: Any] { for child in dict.values {
            if let found = findRatingArray(in: child) { return found }
        } }
        if let array = value as? [Any] { for element in array {
            if let found = findRatingArray(in: element) { return found }
        } }
        return nil
    }

    private func starsForRating(_ rating: Int) -> String {
        switch rating {
        case 0 ..< 1400: "1-Star"
        case 1400 ..< 1600: "2-Star"
        case 1600 ..< 1800: "3-Star"
        case 1800 ..< 2000: "4-Star"
        case 2000 ..< 2200: "5-Star"
        case 2200 ..< 2500: "6-Star"
        default: "7-Star"
        }
    }
}
