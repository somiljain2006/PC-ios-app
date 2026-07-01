//
//  FullScreenImageView.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import SwiftUI
import UIKit

struct FullScreenImageView: View {
    var imageName: String?
    var imageURL: URL?
    var uiImage: UIImage?
    var animation: Namespace.ID
    var onDismiss: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            Group {
                if let imageName {
                    Image(imageName)
                        .resizable()
                } else if let imageURL {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    // Fallback for default profile picture
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .padding(40)
                        .background(Color.primaryContainer)
                }
            }
            .scaledToFit()
            // Dynamically match the ID based on what was provided
            .matchedGeometryEffect(id: imageName ?? imageURL?.absoluteString ?? "defaultProfile", in: animation)
            .offset(y: offset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { value in
                        if abs(value.translation.height) > 150 {
                            onDismiss()
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }
            )
            .onTapGesture {
                onDismiss()
            }

            VStack {
                HStack {
                    Spacer()

                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding()
        }
    }

    private var backgroundOpacity: Double {
        let progress = min(abs(offset.height) / 300, 1)
        return 1 - progress * 0.7
    }
}
