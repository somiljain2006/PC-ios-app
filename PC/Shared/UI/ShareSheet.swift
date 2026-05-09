//
//  ShareSheet.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context)
        -> UIActivityViewController
    {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _: UIActivityViewController,
        context _: Context
    ) {}
}
