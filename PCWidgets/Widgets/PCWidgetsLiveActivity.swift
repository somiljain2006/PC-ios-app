//
//  PCWidgetsLiveActivity.swift
//  PCWidgets
//
//  Created by somil jain on 09/05/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PCWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var emoji: String
    }

    var name: String
}

struct PCWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PCWidgetsAttributes.self) { context in
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PCWidgetsAttributes {
    fileprivate static var preview: PCWidgetsAttributes {
        PCWidgetsAttributes(name: "World")
    }
}

extension PCWidgetsAttributes.ContentState {
    fileprivate static var smiley: PCWidgetsAttributes.ContentState {
        PCWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PCWidgetsAttributes.ContentState {
         PCWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PCWidgetsAttributes.preview) {
   PCWidgetsLiveActivity()
} contentStates: {
    PCWidgetsAttributes.ContentState.smiley
    PCWidgetsAttributes.ContentState.starEyes
}
