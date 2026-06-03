//
//  MomentHomeWidgetLiveActivity.swift
//  MomentHomeWidget
//
//  Created by Mac on 3/6/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MomentHomeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MomentHomeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MomentHomeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
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

extension MomentHomeWidgetAttributes {
    fileprivate static var preview: MomentHomeWidgetAttributes {
        MomentHomeWidgetAttributes(name: "World")
    }
}

extension MomentHomeWidgetAttributes.ContentState {
    fileprivate static var smiley: MomentHomeWidgetAttributes.ContentState {
        MomentHomeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MomentHomeWidgetAttributes.ContentState {
         MomentHomeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MomentHomeWidgetAttributes.preview) {
   MomentHomeWidgetLiveActivity()
} contentStates: {
    MomentHomeWidgetAttributes.ContentState.smiley
    MomentHomeWidgetAttributes.ContentState.starEyes
}
