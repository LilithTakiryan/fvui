//
//  SubscriptionManager.swift
//  fviu
//
//  Created by lilit on 21.06.26.
//

import ApphudSDK
import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: NSObject, ObservableObject, ApphudDelegate {
    static let shared = SubscriptionManager()

    @Published var hasPremium: Bool = false
    @Published var apphudProducts: [ApphudProduct] = []
    @Published var isLoading: Bool = false

    override private init() {
        super.init()
        Apphud.setDelegate(self)
        updateSubscriptionStatusSync()
    }

    nonisolated func updateSubscriptionStatus() {
        Task { @MainActor in
            self.hasPremium = Apphud.hasActiveSubscription()
        }
    }

    private func parsePaywalls(_ paywalls: [ApphudPaywall]) {
        let targetPaywall = paywalls.first(where: { $0.identifier == "main" }) ?? paywalls.first
        
        guard let paywall = targetPaywall else {
            print("paywall not found")
            return
        }
        
        apphudProducts = paywall.products
    }

    func purchase(product: ApphudProduct) async -> Bool {
        guard !isLoading else { return false }

        isLoading = true
        defer { isLoading = false }

        let result = await Apphud.purchaseAsync(product)
        updateSubscriptionStatusSync()

        if let subscription = result.subscription, subscription.isActive() {
            return true
        }
        return result.success
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        await Apphud.restorePurchasesAsync()
        updateSubscriptionStatusSync()
    }

    private func updateSubscriptionStatusSync() {
        hasPremium = Apphud.hasActiveSubscription()
    }


    nonisolated func paywallsDidLoad(_ paywalls: [ApphudPaywall]) {
        Task { @MainActor [weak self] in
            self?.parsePaywalls(paywalls)
        }
    }

    nonisolated func apphudDidChangeSubscriptions(_: [ApphudSubscription]) {
        Task { @MainActor in
            self.updateSubscriptionStatus()
        }
    }

    nonisolated func apphudDidFetchNonRenewingPurchases(_: [ApphudNonRenewingPurchase]) {
        Task { @MainActor in
            self.updateSubscriptionStatus()
        }
    }
}


import ApphudSDK


extension Apphud {
    static func purchaseAsync(_ product: ApphudProduct) async -> ApphudPurchaseResult {
        await withCheckedContinuation { continuation in
            Apphud.purchase(product) { result in
                continuation.resume(returning: result)
            }
        }
    }

    static func restorePurchasesAsync() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Apphud.restorePurchases { _ in
                continuation.resume()
            }
        }
    }
}
