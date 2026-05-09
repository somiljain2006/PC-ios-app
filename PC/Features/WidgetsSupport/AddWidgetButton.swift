//
//  AddWidgetButton.swift
//  PC
//
//  Created by somil jain on 09/05/26.
//

import SwiftUI
import WidgetKit

struct AddWidgetButton: View {
    let type: WidgetType

    @State private var showGuide = false

    var body: some View {
        Button {
            WidgetStorage.setSelectedWidget(type)

            showGuide = true

        } label: {
            HStack {
                Image(systemName: "plus.rectangle.on.rectangle")
                Text("Add to Home Screen")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.onSurface)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.primaryContainer.opacity(0.15))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showGuide) {
            WidgetGuideSheet()
        }
    }
}
