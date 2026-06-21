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
import SwiftUI

class SubscriptionManager: NSObject, ObservableObject, ApphudDelegate {
    static let shared = SubscriptionManager()

    @Published var hasPremium: Bool = false
    @Published var apphudProducts: [ApphudProduct] = []
    @Published var isLoading: Bool = false

    override private init() {
        super.init()

        Apphud.setDelegate(self)

        updateSubscriptionStatus()
    }

    func updateSubscriptionStatus() {
        DispatchQueue.main.async {
            self.hasPremium = Apphud.hasActiveSubscription()
        }
    }

    private func parsePaywalls(_ paywalls: [ApphudPaywall]) {
        for _ in paywalls {}

        if let mainPaywall = paywalls.first(where: { $0.identifier == "main" }) {
            DispatchQueue.main.async {
                self.subManagerProductsUpdate(mainPaywall.products)
            }
        } else {
            print("paywall not found")
            if let firstPw = paywalls.first {
                DispatchQueue.main.async {
                    self.subManagerProductsUpdate(firstPw.products)
                }
            }
        }
    }

    private func subManagerProductsUpdate(_ products: [ApphudProduct]) {
        apphudProducts = products
        for _ in products {}
    }

    func purchase(product: ApphudProduct, completion: @escaping (Bool) -> Void) {
        guard !isLoading else { return }

        DispatchQueue.main.async { self.isLoading = true }

        Apphud.purchase(product) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                self.updateSubscriptionStatus()

                if let subscription = result.subscription, subscription.isActive() {
                    completion(true)
                } else if result.success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func restorePurchases() {
        DispatchQueue.main.async { self.isLoading = true }

        Apphud.restorePurchases { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.updateSubscriptionStatus()
            }
        }
    }

    func paywallsDidLoad(_ paywalls: [ApphudPaywall]) {
        parsePaywalls(paywalls)
    }

    func apphudDidChangeSubscriptions(_: [ApphudSubscription]) {
        updateSubscriptionStatus()
    }

    func apphudDidFetchNonRenewingPurchases(_: [ApphudNonRenewingPurchase]) {
        updateSubscriptionStatus()
    }
}
