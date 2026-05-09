//
//  PCWidgetsBundle.swift
//  PCWidgets
//
//  Created by somil jain on 09/05/26.
//

import WidgetKit
import SwiftUI

@main
struct PCWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PCWidgets()
        LeetCodeWidget()
        CodeforcesWidget()
        CodeChefWidget()
        AtCoderWidget()
        PCWidgetsControl()
        PCWidgetsLiveActivity()
    }
}
