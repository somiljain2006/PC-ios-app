//
//  View+Export.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI

extension View {
    @MainActor
    func exportAsImage() -> UIImage? {
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: self)
            renderer.scale = UIScreen.main.scale
            return renderer.uiImage
        } else {
            let controller = UIHostingController(rootView: ignoresSafeArea())
            guard let view = controller.view else { return nil }

            let targetSize = view.intrinsicContentSize
            view.bounds = CGRect(origin: .zero, size: targetSize)
            view.backgroundColor = .clear

            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

            return renderer.image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
        }
    }
}
