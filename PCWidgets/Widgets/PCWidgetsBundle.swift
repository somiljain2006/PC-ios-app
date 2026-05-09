//
//  PCWidgetsBundle.swift
//  PCWidgets
//
//  Created by somil jain on 09/05/26.
//

import SwiftUI
import WidgetKit

@main
struct PCWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PCWidgets()
        LeetCodeWidget()
        CodeforcesWidget()
        CodeChefWidget()
        AtCoderWidget()
        PCWidgetsControl()
    }
}
