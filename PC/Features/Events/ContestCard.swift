//
//  ContestCard.swift
//  PC
//
//  Created by somil jain on 21/04/26.
//

import SwiftUI

struct ContestSidebarCard: View {
    var contest: AppContest
    var isNotified: Bool
    var onBellTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(contest.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(contest.platform)
                    .font(.caption.bold())
                    .foregroundColor(.onSurfaceVariant)

                Spacer()

                Button(action: onBellTap) {
                    Image(systemName: isNotified ? "bell.fill" : "bell")
                        .foregroundColor(isNotified ? .primaryContainer : .onSurfaceVariant)
                        .padding(6)
                        .background(Color.surfaceContainerLow)
                        .clipShape(Circle())
                }
            }

            Text(contest.shortTitle)
                .font(.headline)
                .foregroundColor(.onSurface)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(contest.formattedDate + " UTC")
                .font(.caption)
                .foregroundColor(.onSurfaceVariant)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(12)
    }
}
