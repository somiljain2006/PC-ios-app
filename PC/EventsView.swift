//
//  EventsView.swift
//  PC
//
//  Created by somil jain on 20/04/26.
//

import SwiftUI

struct EventsView: View {
    @State private var selectedDate: Date?

    @State private var notifiedContests: Set<String> = []
    @State private var showPermissionAlert = false
    private let storageKey = "notifiedContests"

    let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

    let filters: [ContestFilter] = [
        ContestFilter(name: "All", icon: nil),
        ContestFilter(name: "LeetCode", icon: "leetcode"),
        ContestFilter(name: "CodeChef", icon: "codechef"),
        ContestFilter(name: "Codeforces", icon: "codeforces"),
        ContestFilter(name: "AtCoder", icon: "atcoder"),
    ]

    @State private var monthOffset: Int = 0
    @State private var selectedFilter: String = "All"
    @StateObject private var contestService = ContestService()

    private var currentMonthDate: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    private var formattedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonthDate)
    }

    private var filteredContests: [AppContest] {
        if selectedFilter == "All" {
            contestService.allUpcomingContests
        } else {
            contestService.allUpcomingContests.filter { $0.platform == selectedFilter }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                EventsHeaderView()

                VStack(spacing: 16) {
                    VStack(spacing: 16) {
                        CalendarMonthControlView(
                            formattedMonthYear: formattedMonthYear,
                            monthOffset: $monthOffset
                        )

                        TabView(selection: $monthOffset) {
                            ForEach(0 ..< 12, id: \.self) { offset in
                                monthGridView(for: offset)
                                    .tag(offset)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 515)
                    }

                    ContestFilterView(filters: filters, selectedFilter: $selectedFilter)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text(selectedDateTitle)
                        .font(.headline)
                        .foregroundColor(.onSurface)

                    if contestService.isLoading {
                        ProgressView("Fetching contests...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if contestsToShow.isEmpty {
                        Text(selectedDate == nil ? "No upcoming contests found." : "No contests on this day.")
                            .foregroundColor(.onSurfaceVariant)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .transition(.opacity)
                    } else {
                        ForEach(contestsToShow) { contest in
                            ContestSidebarCard(
                                contest: contest,
                                isNotified: notifiedContests.contains(contest.id)
                            ) {
                                handleNotificationToggle(for: contest)
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                }
                .animation(.smooth(duration: 0.3), value: contestsToShow)

                Spacer(minLength: 100)
            }
            .padding()
        }
        .background(Color.background)
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable notifications in Settings to get contest reminders.")
        }
        .task {
            if let saved = UserDefaults.standard.array(forKey: storageKey) as? [String] {
                notifiedContests = Set(saved)
            }
            await contestService.fetchAllContests()

            for contest in contestService.allUpcomingContests
                where notifiedContests.contains(contest.id)
            {
                NotificationManager.shared.scheduleNotification(for: contest)
            }
        }
    }

    @ViewBuilder
    private func monthGridView(for offset: Int) -> some View {
        let targetDate = Calendar.current.date(byAdding: .month, value: offset, to: Date()) ?? Date()
        let daysArray = daysInMonth(for: targetDate)

        VStack(spacing: 1) {
            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.caption2.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.surfaceContainer)
                        .foregroundColor(.onSurfaceVariant)
                }
            }

            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(Array(daysArray.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let todayHighlight = isToday(day: day, monthDate: targetDate)
                        let platformIcons = getIconsFor(day: day, monthDate: targetDate)

                        Button {
                            if let tappedDate = dateFor(day: day, monthDate: targetDate) {
                                if let selectedDate, Calendar.current.isDate(selectedDate, inSameDayAs: tappedDate) {
                                    self.selectedDate = nil
                                } else {
                                    selectedDate = tappedDate
                                }
                            }
                        } label: {
                            CalendarCell(
                                day: "\(day)",
                                icons: platformIcons,
                                color: .clear,
                                isToday: todayHighlight,
                                isSelected: selectedDate.map {
                                    Calendar.current.isDate($0, inSameDayAs: dateFor(day: day, monthDate: targetDate) ?? Date())
                                } ?? false
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        CalendarCell(day: "", icons: [], color: .clear, isToday: false, isSelected: false)
                    }
                }
            }
        }
        .background(Color.outlineVariant.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.outlineVariant.opacity(0.2), lineWidth: 1))
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func daysInMonth(for monthDate: Date) -> [Int?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        guard let firstDayOfMonth = calendar.date(from: components) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return [] }

        var daysArray: [Int?] = Array(repeating: nil, count: firstWeekday - 1)
        daysArray.append(contentsOf: (1 ... range.count).map { $0 })

        let remainder = daysArray.count % 7
        if remainder > 0 {
            daysArray.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
        }

        return daysArray
    }

    private func dateFor(day: Int, monthDate: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month], from: monthDate)
        components.day = day
        return Calendar.current.date(from: components)
    }

    private func isToday(day: Int, monthDate: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        guard calendar.component(.month, from: monthDate) == calendar.component(.month, from: today),
              calendar.component(.year, from: monthDate) == calendar.component(.year, from: today)
        else {
            return false
        }
        return calendar.component(.day, from: today) == day
    }

    private func getIconsFor(day: Int, monthDate: Date) -> [String] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: monthDate)
        let currentYear = calendar.component(.year, from: monthDate)

        var iconsForDay: [String] = []

        for contest in filteredContests {
            let contestDay = calendar.component(.day, from: contest.startTime)
            let contestMonth = calendar.component(.month, from: contest.startTime)
            let contestYear = calendar.component(.year, from: contest.startTime)

            if contestDay == day, contestMonth == currentMonth, contestYear == currentYear {
                if !iconsForDay.contains(contest.icon) {
                    iconsForDay.append(contest.icon)
                }
            }
        }
        return iconsForDay
    }

    private var contestsToShow: [AppContest] {
        guard let selectedDate else { return filteredContests }
        return filteredContests.filter {
            Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate)
        }
    }

    private var selectedDateTitle: String {
        guard let selectedDate else { return "All Upcoming Contests" }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    private func handleNotificationToggle(for contest: AppContest) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        NotificationManager.shared.checkPermission { status in
            switch status {
            case .authorized, .provisional:
                toggleNotification(contest)

            case .notDetermined:
                NotificationManager.shared.requestPermission { granted in
                    if granted {
                        toggleNotification(contest)
                    } else {
                        showPermissionAlert = true
                    }
                }

            default:
                showPermissionAlert = true
            }
        }
    }

    private func toggleNotification(_ contest: AppContest) {
        if notifiedContests.contains(contest.id) {
            notifiedContests.remove(contest.id)
            NotificationManager.shared.cancelNotification(for: contest)
        } else {
            notifiedContests.insert(contest.id)
            NotificationManager.shared.scheduleNotification(for: contest)
        }

        UserDefaults.standard.set(Array(notifiedContests), forKey: storageKey)
    }

    private func scheduleAndSave(contest: AppContest) {
        notifiedContests.insert(contest.id)
        UserDefaults.standard.set(Array(notifiedContests), forKey: storageKey)
    }
}

struct EventsHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upcoming ")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.onSurface)
                + Text("Contests")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.primaryContainer)

            Text("Global coding competitions calendar. Filter, track, and prepare for your next rating climb.")
                .font(.system(size: 16))
                .foregroundColor(.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 20)
    }
}

#Preview {
    EventsView()
}
