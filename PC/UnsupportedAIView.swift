//
//  UnsupportedAIView.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI

struct UnsupportedAIView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 42))

            Text("Ask PC Requires Newer iOS")
                .font(.headline)

            Text("Apple Intelligence features are available only on supported iOS versions.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
