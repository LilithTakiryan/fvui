//
//  PaywallScreen.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import ApphudSDK
import StoreKit
import SwiftUI

#Preview {
    PaywallScreen()
        .environmentObject(SubscriptionManager.shared)
}

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
    @State private var setupTask: Task<Void, Never>?

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

                HeaderSection()
                FeaturesList()
                CardsSection(options: $options, selectedId: $selectedId)
                CancelIndicator()
                ActionButton(options: options, selectedId: selectedId, subManager: subManager)
                FooterLinks(subManager: subManager)

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
                            .font(CustomConstants.Typography.semiBold16)
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

            setupTask = Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                withAnimation(.easeOut(duration: 0.3)) {
                    showButton = true
                }
            }
        }
        .onChange(of: subManager.apphudProducts) { _ in
            loadApphudProducts()
        }
        .onDisappear {
            setupTask?.cancel()
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
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? ""
    }
}
