//
//  NotificationManager.swift
//  PC
//
//  Created by somil jain on 21/04/26.
//

import UserNotifications

enum ReminderTime {
    case fiveMin, fifteenMin, oneHour

    var timeInterval: TimeInterval {
        switch self {
        case .fiveMin: -300
        case .fifteenMin: -900
        case .oneHour: -3600
        }
    }
}

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func checkPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleNotification(for contest: AppContest, reminderTime: ReminderTime = .fifteenMin) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contest.id])
        let content = UNMutableNotificationContent()
        content.title = contest.title
        content.body = "\(contest.platform) contest is starting!"
        content.sound = .default

        let triggerDate = contest.startTime.addingTimeInterval(reminderTime.timeInterval)

        if triggerDate < Date() { return }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: triggerDate
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: contest.id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for contest: AppContest) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [contest.id]
        )
    }
}
