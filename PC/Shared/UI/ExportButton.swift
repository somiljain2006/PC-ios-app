//
//  ExportButton.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI

struct ExportButton<Content: View>: View {
    let content: Content

    @State private var showShare = false
    @State private var exportedImage: UIImage?

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Button {
            Task {
                await export()
            }

        } label: {
            HStack {
                Image(systemName: "square.grid.2x2")
                Text("Export Widget")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.onSurface)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.surfaceContainerHighest)
            .cornerRadius(12)
        }
        .sheet(isPresented: $showShare) {
            if let exportedImage {
                ShareSheet(items: [exportedImage])
            }
        }
    }

    @MainActor
    private func export() async {
        let image = content
            .padding()
            .background(Color.background)
            .frame(width: 390)

        exportedImage = image.exportAsImage()

        showShare = exportedImage != nil
    }
}
