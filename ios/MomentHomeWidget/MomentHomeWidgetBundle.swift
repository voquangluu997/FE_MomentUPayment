//
//  MomentHomeWidgetBundle.swift
//  MomentHomeWidget
//
//  Created by Mac on 3/6/26.
//

import WidgetKit
import SwiftUI

@main
struct MomentHomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        MomentHomeWidget()
        MomentHomeWidgetControl()
        MomentHomeWidgetLiveActivity()
    }
}
