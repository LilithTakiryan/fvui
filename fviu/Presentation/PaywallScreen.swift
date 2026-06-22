//
//  SubscriptionOption.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import SwiftUI

#Preview {
    PaywallScreen()
}

import ApphudSDK
import StoreKit
import SwiftUI

struct SubscriptionOption: Identifiable {
    let id: String
    let duration: String
    let weeklyPrice: String
    let fullPrice: String
    let discountBadge: String?
    let rawProduct: ApphudProduct?
}

struct PaywallScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subManager: SubscriptionManager

    @State private var options = [
        SubscriptionOption(id: "yearly_product_id", duration: "Year", weeklyPrice: "$1.27", fullPrice: "$69.99", discountBadge: "SAVE 80%", rawProduct: nil),
        SubscriptionOption(id: "monthly_product_id", duration: "Month", weeklyPrice: "$1.99", fullPrice: "$7.99", discountBadge: nil, rawProduct: nil),
    ]

    @State private var selectedId: String?
    @State private var showButton = false

    var body: some View {
        ZStack {
            CustomConstants.Colors.backgroundDeep.ignoresSafeArea()

            if subManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .zIndex(1)
            }

            VStack(spacing: 24) {
                Spacer()

                headerSection
                featuresList
                cardsSection
                cancelIndicator
                actionButton
                footerLinks

                Spacer()
            }
            .padding(.horizontal, 16)
            .disabled(subManager.isLoading)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showButton {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .onAppear {
            if selectedId == nil {
                selectedId = options.first?.id
            }

            loadApphudProducts()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showButton = true
                }
            }
        }

        .onChange(of: subManager.apphudProducts) { _ in
            loadApphudProducts()
        }
    }

    private func loadApphudProducts() {
        let products = subManager.apphudProducts
        guard !products.isEmpty else { return }

        options = products.map { apphudProduct in
            let skProduct = apphudProduct.skProduct
            let localizedPrice = skProduct?.localizedPrice ?? ""

            let isYear = apphudProduct.productId.contains("year")
            let duration = isYear ? "Year" : "Month"
            let weekly = isYear ? "$1.27" : "$1.99"
            let badge = isYear ? "SAVE 80%" : nil

            return SubscriptionOption(
                id: apphudProduct.productId,
                duration: duration,
                weeklyPrice: weekly,
                fullPrice: localizedPrice,
                discountBadge: badge,
                rawProduct: apphudProduct
            )
        }

        if let firstId = options.first?.id, selectedId == "yearly_product_id" || selectedId == "monthly_product_id" {
            selectedId = firstId
        }
    }

    private var headerSection: some View {
        Text("Create anything you want")
            .foregroundColor(.white)
            .font(.system(size: 34, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    private var cardsSection: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                subscriptionCard(for: option)
            }
        }
    }

    private func subscriptionCard(for option: SubscriptionOption) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(option.duration)
                        .font(.system(size: 20, weight: .bold))
                    Text("\(option.weeklyPrice) / week")
                        .font(.system(size: 20, weight: .medium))
                }
                .foregroundColor(.white)

                Text(option.fullPrice)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CustomConstants.Paywall.subTextColor)
            }

            Spacer()

            if let badgeText = option.discountBadge {
                Text(badgeText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(CustomConstants.Colors.brandGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .brandCardStyle(cornerRadius: 24, isSelected: selectedId == option.id)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedId = option.id
            }
        }
    }

    private var cancelIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
            Text("Cancel anytime")
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(CustomConstants.Paywall.subTextColor)
    }

    private var actionButton: some View {
        Button(action: {
            if let selectedOption = options.first(where: { $0.id == selectedId }),
               let realProduct = selectedOption.rawProduct
            {
                subManager.purchase(product: realProduct) { success in
                    if success { print("purchase success") }
                }
            } else {
                print("not loaded yet")
            }
        }) {
            Text("Unlock now")
        }
        .buttonStyle(CustomCapsuleButtonStyle(
            background: CustomConstants.Colors.brandGradient,
            verticalPadding: CustomConstants.Sizes.mainButtonVerticalPadding,
            isScaled: true
        ))
    }

    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(icon: .sparkles, title: "Get results in seconds")
            featureRow(icon: .edit, title: "Turn any text into better writing")
            featureRow(icon: .text, title: "Simplify complex information")
            featureRow(icon: .image, title: "Create content with AI templates")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }

    private var footerLinks: some View {
        HStack {
            Text("Privacy policy")
            Spacer()
            Button("Restore purchases") {
                subManager.restorePurchases()
            }
            Spacer()
            Text("Terms of use")
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(CustomConstants.Paywall.subTextColor)
        .padding(.horizontal, 10)
    }

    private func featureRow(icon: ImageResource, title: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .frame(width: 20, height: 20)

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    PaywallScreen()
        .environmentObject(SubscriptionManager.shared)
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? ""
    }
}
