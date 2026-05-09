//
//  AppIntent.swift
//  PCWidgets
//
//  Created by somil jain on 09/05/26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    @Parameter(title: "Favorite Emoji", default: ":)")
    var favoriteEmoji: String
}
