//
//  ProfileSheetOverlay.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI

struct ProfileSheetOverlay: View {
    @ObservedObject var profileService: ProfileService
    @Binding var showProfileSheet: Bool

    @GestureState private var profileDragOffset: CGFloat = 0
    @State private var profileOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showProfileSheet = false } }

            HStack {
                Spacer()
                let width: CGFloat = 300
                ProfileMenuView(
                    profileService: profileService,
                    onClose: {
                        withAnimation {
                            showProfileSheet = false
                            profileOffset = 0
                        }
                    }
                )
                .frame(width: width)
                .background(Color.background)
                .offset(x: max(profileOffset + profileDragOffset, 0))
                .gesture(
                    DragGesture()
                        .updating($profileDragOffset) { value, state, _ in
                            if value.translation.width > 0 { state = value.translation.width }
                        }
                        .onEnded { value in
                            if value.translation.width > width * 0.3 {
                                withAnimation {
                                    showProfileSheet = false
                                    profileOffset = 0
                                }
                            } else {
                                withAnimation { profileOffset = 0 }
                            }
                        }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .zIndex(10)
    }
}
