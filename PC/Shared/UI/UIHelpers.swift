//
//  UIHelpers.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import SwiftUI
import UIKit

func triggerHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.prepare()
    generator.impactOccurred()
}

struct BottomSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func bottomSheetStyle() -> some View {
        modifier(BottomSheetModifier())
            .applySheetStyle()
    }
}

private extension View {
    @ViewBuilder
    func applySheetStyle() -> some View {
        if #available(iOS 16.0, *) {
            presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }
}
