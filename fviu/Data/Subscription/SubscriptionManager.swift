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
import os.log

@MainActor
final class SubscriptionManager: NSObject, ObservableObject, ApphudDelegate {
    static let shared = SubscriptionManager()
    
    private let logger = Logger(subsystem: "com.video", category: "SubscriptionManager")

    @Published var hasPremium: Bool = false
    @Published var apphudProducts: [ApphudProduct] = []
    @Published var isLoading: Bool = false

    override private init() {
        super.init()
        Apphud.setDelegate(self)
        updateSubscriptionStatusSync()
        logger.info("SubscriptionManager initialized")
    }

    nonisolated func updateSubscriptionStatus() {
        Task { @MainActor in
            self.hasPremium = Apphud.hasActiveSubscription()
            self.logger.info("hasPremium updated: \(self.hasPremium, privacy: .public)")
        }
    }

    private func parsePaywalls(_ paywalls: [ApphudPaywall]) {
        logger.info("Paywalls loaded: \(paywalls.count, privacy: .public)")
        
        for paywall in paywalls {
            logger.debug("Paywall '\(paywall.identifier, privacy: .public)': \(paywall.products.count, privacy: .public) products")
        }
        
        let targetPaywall = paywalls.first(where: { $0.identifier == "main" }) ?? paywalls.first
        
        guard let paywall = targetPaywall else {
            logger.error("Paywall not found")
            return
        }
        
        apphudProducts = paywall.products
        logger.info("Loaded \(self.apphudProducts.count, privacy: .public) products for purchase")
    }

    func purchase(product: ApphudProduct) async -> Bool {
        guard !isLoading else {
            logger.warning("Already loading, ignoring purchase request")
            return false
        }

        isLoading = true
        defer { isLoading = false }

        logger.info("Purchasing: \(product.productId, privacy: .public)")
        let result = await Apphud.purchaseAsync(product)
        
        logger.debug("Purchase result - success: \(result.success, privacy: .public), has subscription: \(result.subscription != nil, privacy: .public)")
        
        // Update subscription status immediately after purchase
        updateSubscriptionStatusSync()

        if let subscription = result.subscription, subscription.isActive() {
            logger.info("✅ Purchase successful, subscription is active")
            return true
        }
        
        if result.success {
            logger.info("✅ Purchase successful")
            return true
        }
        
        logger.error("Purchase failed")
        return false
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        logger.info("Starting restore purchases...")
        await Apphud.restorePurchasesAsync()
        updateSubscriptionStatusSync()
        logger.info("Restore purchases complete")
    }

    private func updateSubscriptionStatusSync() {
        hasPremium = Apphud.hasActiveSubscription()
        logger.info("Subscription status synced: hasPremium = \(self.hasPremium, privacy: .public)")
    }

    nonisolated func paywallsDidLoad(_ paywalls: [ApphudPaywall]) {
        Task { @MainActor [weak self] in
            self?.logger.info("paywallsDidLoad delegate fired with \(paywalls.count, privacy: .public) paywalls")
            self?.parsePaywalls(paywalls)
        }
    }

    nonisolated func apphudDidChangeSubscriptions(_ subscriptions: [ApphudSubscription]) {
        Task { @MainActor in
            self.logger.info("apphudDidChangeSubscriptions delegate fired with \(subscriptions.count, privacy: .public) subscriptions")
            self.updateSubscriptionStatus()
        }
    }

    nonisolated func apphudDidFetchNonRenewingPurchases(_ purchases: [ApphudNonRenewingPurchase]) {
        Task { @MainActor in
            self.logger.info("apphudDidFetchNonRenewingPurchases delegate fired with \(purchases.count, privacy: .public) purchases")
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
