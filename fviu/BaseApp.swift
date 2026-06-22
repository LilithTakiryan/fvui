//
//  fviuApp.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//
import ApphudSDK
import SwiftUI

@main
struct BaseApp: App {
    @StateObject private var subscriptionManager: SubscriptionManager

    let paymentToken = API.TokenProvider.payment.value

    init() {
        Apphud.start(apiKey: paymentToken)

        _subscriptionManager = StateObject(wrappedValue: SubscriptionManager.shared)
    }

    var body: some Scene {
        WindowGroup {
//            if subscriptionManager.hasPremium {
            MainScreen()
                .environmentObject(subscriptionManager)
                .font(.custom(CustomConstants.Typography.fontName, size: 16))

//            } else {
//                PaywallScreen()
//                    .environmentObject(subscriptionManager)
//            }
        }
    }
}
