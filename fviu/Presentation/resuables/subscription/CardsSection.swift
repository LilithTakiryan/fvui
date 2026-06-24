//
//  CardsSection.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

import SwiftUI

struct CardsSection: View {
    @Binding var options: [SubscriptionOption]
    @Binding var selectedId: String?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                SubscriptionCard(
                    option: option,
                    isSelected: selectedId == option.id,
                    onSelect: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedId = option.id
                        }
                    }
                )
            }
        }
    }
}
struct SubscriptionCard: View {
    let option: SubscriptionOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(option.duration)
                        .font(CustomConstants.Typography.regular16)
                    Text("\(option.weeklyPrice) / week")
                        .font(CustomConstants.Typography.regular14)
                }
                .foregroundColor(.white)

                Text(option.fullPrice)
                    .font(CustomConstants.Typography.medium16)
                    .foregroundColor(CustomConstants.Paywall.subTextColor)
            }

            Spacer()

            if let badgeText = option.discountBadge {
                Text(badgeText)
                    .font(CustomConstants.Typography.regular16)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(CustomConstants.Colors.brandGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .brandCardStyle(
            cornerRadius: CustomConstants.CornerRadius.radius,
            isSelected: isSelected
        )
        .onTapGesture(perform: onSelect)
    }
}
