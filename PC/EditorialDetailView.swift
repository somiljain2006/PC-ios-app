//
//  EditorialDetailView.swift
//  PC
//
//  Created by somil jain on 23/04/26.
//

import SwiftUI

struct EditorialDetailView: View {
    let editorial: PCEditorialDetail
    @Environment(\.dismiss) private var dismiss
    @State private var expandedQuestionID: Int?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(editorial.contestName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.onSurface)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(editorial.contestDate)
                            .font(.caption.bold())
                            .foregroundColor(.primaryContainer)

                        if let url = URL(string: editorial.contestLink) {
                            Link(destination: url) {
                                Text("Open contest link")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.top, 8)

                    ForEach(Array(editorial.questions.enumerated()), id: \.element.id) { index, question in
                        QuestionCard(
                            question: question,
                            index: index + 1,
                            isExpanded: expandedQuestionID == question.id,
                            onToggle: {
                                withAnimation(.smooth) {
                                    expandedQuestionID =
                                        expandedQuestionID == question.id ? nil : question.id
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color.background.ignoresSafeArea())
            .navigationTitle("Editorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.primaryContainer)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct QuestionCard: View {
    let question: PCEditorialDetailQuestion
    let index: Int
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Question \(index)")
                            .font(.caption.bold())
                            .foregroundColor(.onSurfaceVariant)

                        Text(question.questionName)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.onSurface)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundColor(.primaryContainer)
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    if let url = URL(string: question.questionLink) {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            HStack(spacing: 6) {
                                Text("Visit problem")
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.headline)
                            .foregroundColor(.onSurface)
                        }
                        .buttonStyle(.plain)
                    }

                    if let explanation = question.explanation, !explanation.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Explanation")
                                .font(.headline)
                                .foregroundColor(.onSurface)

                            Text(explanation)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.onSurfaceVariant)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.black.opacity(0.35))
                                .cornerRadius(16)
                        }
                    }

                    if let code = question.code, !code.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Code")
                                .font(.headline)
                                .foregroundColor(.onSurface)

                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(code)
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(.onSurfaceVariant)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.35))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding([.horizontal, .bottom], 16)
                .padding(.top, 4)
            }
        }
        .background(Color.surfaceContainerLow)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.outlineVariant.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(16)
        .tint(.primaryContainer)
    }
}
