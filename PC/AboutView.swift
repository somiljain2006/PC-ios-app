//
//  AboutView.swift
//  PC
//
//  Created by somil jain on 19/04/26.
//

import SwiftUI

struct AboutView: View {
    @Namespace private var animation
    @State private var selectedImage: ActiveImage?

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            Text("Our")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color.onSurface)
                                + Text(" Achievements")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color.primaryContainer)

                            Rectangle()
                                .fill(Color.primaryContainer)
                                .frame(width: 96, height: 4)
                                .cornerRadius(2)

                            Text("""
                            Here are a few of our proudest accomplishments in competitive programming.
                            """)
                            .font(.system(size: 14))
                            .foregroundColor(Color.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)

                        VStack(spacing: 16) {
                            AchievementCard(
                                icon: "icpc1",
                                title: "ICPC Regionalist '24",
                                subtitle: "Qualified for the Amritapuri Doublesite Regional Contest."
                            )

                            AchievementCard(
                                icon: "icpc2",
                                title: "ICPC Regionalist '23",
                                subtitle: "Achieved regionalist status at the Kanpur and Chennai sites."
                            )

                            AchievementCard(
                                icon: "excellence",
                                title: "Team Excellence",
                                subtitle: "Recognized for outstanding teamwork and perseverance."
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 10) {
                            Text("Our ")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color.onSurface)
                                +
                                Text("Team")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color.primaryContainer)

                            Rectangle()
                                .fill(Color.primaryContainer)
                                .frame(width: 96, height: 4)
                                .cornerRadius(2)

                            Text("""
                            A strong and growing community of 56 passionate coders across different years.
                            """)
                            .font(.system(size: 14))
                            .foregroundColor(Color.onSurfaceVariant)
                            .lineSpacing(4)
                            .padding(.top, 4)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 16) {
                            MemberGroupCard(
                                year: "4th Year",
                                count: 22,
                                imageName: "year4_photo"
                            )

                            MemberGroupCard(
                                year: "3rd Year",
                                count: 21,
                                imageName: "year3_photo"
                            )

                            MemberGroupCard(
                                year: "2nd Year",
                                count: 13,
                                imageName: "year2_photo"
                            )
                        }
                    }

                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            Text("Photo ")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color.onSurface)
                                +
                                Text("Gallery")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color.primaryContainer)

                            Rectangle()
                                .fill(Color.primaryContainer)
                                .frame(width: 96, height: 4)
                                .cornerRadius(2)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 16) {
                            GalleryItem(
                                imageName: "asia1",
                                caption: "ICPC Asia Amritapuri Regional Contest 2024",
                                animation: animation,
                                isSelected: selectedImage?.name == "asia1"
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    selectedImage = ActiveImage(name: "asia1")
                                }
                            }

                            GalleryItem(
                                imageName: "asia2",
                                caption: "ICPC Asia Chennai Regional Contest 2023",
                                animation: animation,
                                isSelected: selectedImage?.name == "asia2"
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    selectedImage = ActiveImage(name: "asia2")
                                }
                            }

                            GalleryItem(
                                imageName: "asia3",
                                caption: "ICPC Kanpur Site Regional Contest 2023",
                                animation: animation,
                                isSelected: selectedImage?.name == "asia3"
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    selectedImage = ActiveImage(name: "asia3")
                                }
                            }
                        }
                    }

                    Spacer(minLength: 88)
                }
                .padding()
                .padding(.top, 12)
                .frame(maxWidth: .infinity)
            }
            if let selectedImage {
                FullScreenImageView(
                    imageName: selectedImage.name,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        self.selectedImage = nil
                    }
                }
                .zIndex(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    AboutView()
}
