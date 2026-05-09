//
//  ContestFilterView.swift
//  PC
//
//  Created by somil jain on 21/04/26.
//

import SwiftUI

struct ContestFilterView: View {
    let filters: [ContestFilter]
    @Binding var selectedFilter: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(.smooth(duration: 0.3)) {
                            selectedFilter = filter.name
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if let icon = filter.icon {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                            Text(filter.name)
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedFilter == filter.name ? Color.primaryContainer : Color.surfaceContainerHigh)
                        .foregroundColor(selectedFilter == filter.name ? Color.onPrimaryContainer : Color.onSurfaceVariant)
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
}
