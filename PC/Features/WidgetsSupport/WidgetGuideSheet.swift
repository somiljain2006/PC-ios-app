//
//  WidgetGuideSheet.swift
//  PC
//
//  Created by somil jain on 09/05/26.
//

import SwiftUI

struct WidgetGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryContainer)

                VStack(spacing: 10) {
                    Text("Add Widget")
                        .font(.title.bold())

                    Text("""
                    1. Go to Home Screen

                    2. Long press anywhere

                    3. Tap the + button

                    4. Search for PC

                    5. Select your widget
                    """)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}
