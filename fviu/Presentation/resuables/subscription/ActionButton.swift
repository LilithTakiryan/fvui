//
//  ActionButton.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

import SwiftUI
import ApphudSDK

struct ActionButton: View {
    let options: [SubscriptionOption]
    let selectedId: String?
    @ObservedObject var subManager: SubscriptionManager
    
    @Environment(\.dismiss) var dismiss
    
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
        guard let selectedId = selectedId,
              let selectedOption = options.first(where: { $0.id == selectedId }),
              let product = selectedOption.rawProduct else {
            return
        }
        
        Task {
            let success = await subManager.purchase(product: product)
            if success {
                dismiss()
            }
        }
    }
}
