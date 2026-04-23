//
//  EditorialComponents.swift
//  PC
//
//  Created by somil jain on 23/04/26.
//

import SwiftUI

struct PCEditorialCard: View {
    let editorial: PCEditorial
    let onOpenEditorial: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                HStack(spacing: 12) {
                    Image(getPlatformIcon(editorial.platform))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())

                    Text(editorial.contestName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.onSurface)
                }

                Spacer()

                Text(formatDate(editorial.contestDate))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.surfaceContainerHighest)
                    .cornerRadius(6)
            }

            Divider()
                .background(Color.outlineVariant.opacity(0.3))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(editorial.questions.enumerated()), id: \.element.id) { index, question in
                    let letter = excelColumnName(index)
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(letter).")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primaryContainer)

                        Text(question.questionName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }
            }

            HStack {
                Spacer()

                Button {
                    onOpenEditorial()
                } label: {
                    HStack(spacing: 6) {
                        Text("Open Editorial")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.primaryContainer)
                    .cornerRadius(999)
                }
            }
        }
        .padding(16)
        .background(Color.surfaceContainerLow)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.outlineVariant.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(16)
    }

    private func getPlatformIcon(_ platform: String) -> String {
        switch platform {
        case "LC": "leetcode"
        case "CC": "codechef"
        case "CF": "codeforces"
        case "AT": "atcoder"
        default: "globe"
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd MMM"
            return formatter.string(from: date)
        }
        return dateString
    }

    func excelColumnName(_ index: Int) -> String {
        var index = index
        var result = ""

        repeat {
            let remainder = index % 26
            let scalar = UnicodeScalar(UInt8(65 + remainder))
            result = String(scalar) + result
            index = index / 26 - 1
        } while index >= 0

        return result
    }
}

struct FeaturedBlogCard: View {
    let post: EditorialPost

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.secondaryContainer.opacity(0.30),
                    Color.primaryContainer.opacity(0.20),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)

            VStack(alignment: .leading, spacing: 14) {
                Text("FEATURED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.primary)
                    .textCase(.uppercase)
                    .modifier(LetterSpacing(value: 2))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.10))
                    .cornerRadius(4)

                Text(post.title)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                Text("\(post.readTime) • Level: \(post.level)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.onSurfaceVariant)
                    .lineLimit(1)

                HStack {
                    let initials = initials(from: post.author)

                    if initials.isEmpty {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.surfaceContainerHigh)
                            .overlay(
                                Circle().stroke(Color.surface, lineWidth: 2)
                            )
                            .clipShape(Circle())
                    } else {
                        Text(initials)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.surfaceContainerHigh)
                            .overlay(
                                Circle().stroke(Color.surface, lineWidth: 2)
                            )
                            .clipShape(Circle())
                    }

                    Text("@\(post.author)")
                        .font(.system(size: 12))
                        .foregroundColor(.outline)

                    Spacer()

                    Button {
                        if let url = URL(string: "https://codeforces.com/blog/entry/\(post.id)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("READ ARTICLE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.onPrimaryContainer)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.primaryContainer)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .frame(maxHeight: .infinity)
            .background(Color.surfaceContainerLow)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.outlineVariant.opacity(0.10), lineWidth: 1)
            )
        }
        .cornerRadius(12)
    }

    private func initials(from name: String) -> String {
        let letters = name.filter(\.isLetter)

        if letters.isEmpty {
            return ""
        } else if letters.count == 1 {
            return String(letters.prefix(1)).uppercased()
        } else {
            return String(letters.prefix(2)).uppercased()
        }
    }
}

struct FeaturedBlogSkeleton: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.surfaceContainerLow

            VStack(alignment: .leading, spacing: 14) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceContainerHigh)
                    .frame(width: 80, height: 12)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceContainerHigh)
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceContainerHigh)
                    .frame(height: 20)

                Spacer()

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceContainerHigh)
                    .frame(width: 140, height: 12)

                HStack {
                    Circle()
                        .fill(Color.surfaceContainerHigh)
                        .frame(width: 32, height: 32)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.surfaceContainerHigh)
                        .frame(width: 100, height: 12)

                    Spacer()
                }
            }
            .padding(20)
        }
        .overlay(
            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.11),
                    .clear,
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(20))
            .offset(x: animate ? 400 : -400)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
        .cornerRadius(12)
    }
}
