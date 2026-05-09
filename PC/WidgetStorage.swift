//
//  WidgetStorage.swift
//  PC
//
//  Created by somil jain on 09/05/26.
//

import Foundation
import WidgetKit

enum WidgetStorage {
    static let suite = UserDefaults(
        suiteName: "group.com.pc.app"
    )

    static func setSelectedWidget(
        _ type: WidgetType
    ) {
        suite?.set(
            type.rawValue,
            forKey: "selected_widget"
        )

        WidgetCenter.shared.reloadAllTimelines()
    }
}
