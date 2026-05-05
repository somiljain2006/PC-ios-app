//
//  PCApp.swift
//  PC
//
//  Created by somil jain on 10/04/26.
//

import Supabase
import SwiftUI

@main
struct PCApp: App {
    @State private var showResetPasswordSheet = false

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showResetPasswordSheet) {
                    UpdatePasswordView()
                }
                .onOpenURL { url in
                    print("Incoming URL:", url)

                    Task {
                        do {
                            try await SupabaseManager.shared.client.auth.session(from: url)
                            print("Session restored!")

                            if url.absoluteString.contains("type=recovery") {
                                await MainActor.run {
                                    showResetPasswordSheet = true
                                }
                            }

                        } catch {
                            print("Failed to restore session:", error)
                        }
                    }
                }
        }
    }

    final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        static let shared = NotificationDelegate()

        func userNotificationCenter(
            _: UNUserNotificationCenter,
            willPresent _: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            completionHandler([.banner, .sound])
        }
    }
}
