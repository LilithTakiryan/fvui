//
//  fviuApp.swift
//  fviu
//

import ApphudSDK
import SwiftUI
import os.log

@main
struct BaseApp: App {
    @StateObject private var subscriptionManager: SubscriptionManager
    private let logger = Logger(subsystem: "com.video", category: "BaseApp")

    let paymentToken = APIconstants.TokenProvider.payment.value

    init() {
        _subscriptionManager = StateObject(wrappedValue: SubscriptionManager.shared)
        
        Apphud.start(apiKey: paymentToken)
        logger.info("Apphud initialized, delegate ready")
    }

    var body: some Scene {
        WindowGroup {
            MainScreen()
                .environmentObject(subscriptionManager)
                .font(.custom(CustomConstants.Typography.fontName, size: 16))
        }
    }
}
