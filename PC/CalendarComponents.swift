//
//  CalendarComponents.swift
//  PC
//
//  Created by somil jain on 21/04/26.
//

import SwiftUI

struct CalendarArrow: View {
    var icon: String
    var body: some View {
        Image(systemName: icon)
            .padding(8)
            .background(Color.surfaceContainerHigh)
            .cornerRadius(8)
            .foregroundColor(.onSurface)
    }
}

struct CalendarCell: View {
    var day: String
    var icons: [String]
    var color: Color
    var isToday: Bool
    var isSelected: Bool

    var body: some View {
        VStack {
            Text(day)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isToday ? Color.onPrimaryContainer : .onSurfaceVariant)
                .frame(width: 24, height: 24)
                .background(isToday ? Color.primaryContainer : Color.clear)
                .clipShape(Circle())
                .padding(.top, 4)

            Spacer()

            if icons.count == 1 {
                if let iconName = icons.first {
                    if iconName == "codechef" || iconName == "atcoder" {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 32, height: 32)
                            Image(iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                        }
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                    }
                }

            } else if icons.count > 1 {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primaryContainer)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(
            day.isEmpty ? Color.surfaceContainerLow.opacity(0.5) :
                (isSelected ? Color.primaryContainer.opacity(0.18) :
                    (isToday ? Color.primaryContainer.opacity(0.1) : Color.background))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(isSelected ? Color.primaryContainer : Color.clear, lineWidth: 1)
        )
    }
}

struct CalendarMonthControlView: View {
    var formattedMonthYear: String
    @Binding var monthOffset: Int

    var body: some View {
        HStack {
            Text(formattedMonthYear)
                .font(.headline)
                .foregroundColor(.onSurface)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut) { monthOffset = max(0, min(11, monthOffset - 1)) }
                } label: {
                    CalendarArrow(icon: "chevron.left")
                        .opacity(monthOffset == 0 ? 0.3 : 1.0)
                }
                .disabled(monthOffset == 0)

                Button {
                    withAnimation(.easeInOut) { monthOffset = max(0, min(11, monthOffset + 1)) }
                } label: {
                    CalendarArrow(icon: "chevron.right")
                        .opacity(monthOffset == 11 ? 0.3 : 1.0)
                }
                .disabled(monthOffset == 11)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.surfaceContainerLow)
        .cornerRadius(12)
    }
}
