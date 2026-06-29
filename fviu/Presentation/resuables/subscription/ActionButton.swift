//
//  ActionButton.swift
//  fviu
//

import SwiftUI
import ApphudSDK
import os.log

struct ActionButton: View {
    let options: [SubscriptionOption]
    let selectedId: String?
    @ObservedObject var subManager: SubscriptionManager
    
    @Environment(\.dismiss) var dismiss
    
    private let logger = Logger(subsystem: "com.video", category: "ActionButton")
    
    var body: some View {
        Button(action: handlePurchase) {
            if subManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Unlock now")
                    .font(CustomConstants.Typography.semiBold16)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(CustomCapsuleButtonStyle(
            background: CustomConstants.Colors.brandGradient,
            verticalPadding: CustomConstants.Sizes.mainButtonVerticalPadding,
            isScaled: true
        ))
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
        .disabled(selectedId == nil || subManager.isLoading)
    }
    
    private func handlePurchase() {
        logger.info("Purchase button tapped, selectedId: \(self.selectedId ?? "nil", privacy: .public)")
        
        guard let selectedId = selectedId,
              let selectedOption = options.first(where: { $0.id == selectedId }) else {
            logger.error("No selection found")
            return
        }
        
        logger.info("Selected option: \(selectedOption.duration, privacy: .public)")
        
        Task {
            if let product = selectedOption.rawProduct {
                logger.info("Processing real Apphud purchase: \(product.productId, privacy: .public)")
                let success = await subManager.purchase(product: product)
                if success {
                    logger.info("Purchase succeeded, dismissing paywall")
                    dismiss()
                } else {
                    logger.error("Purchase failed in SubscriptionManager")
                }
            } else {
                logger.warning("Test mode: rawProduct is nil, simulating purchase")
                
                subManager.isLoading = true
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 sec
                
                subManager.hasPremium = true
                subManager.isLoading = false
                
                logger.info("Test purchase simulated, hasPremium = true")
                dismiss()
            }
        }
    }
}
