//
//  LetterSpacing.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import SwiftUI

struct LetterSpacing: ViewModifier {
    var value: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                Text("")
                    .tracking(value)
                    .opacity(0)
            )
    }
}
