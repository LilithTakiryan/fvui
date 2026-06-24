//
//  ActionButton.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//


import SwiftUI

struct ActionButton: View {
    let options: [SubscriptionOption]
    let selectedId: String?
    @ObservedObject var subManager: SubscriptionManager

    var body: some View {
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
                .font(CustomConstants.Typography.spProDisplayRegular12)
        }
        .buttonStyle(CustomCapsuleButtonStyle(
            background: CustomConstants.Colors.brandGradient,
            verticalPadding: CustomConstants.Sizes.mainButtonVerticalPadding,
            isScaled: true
        ))
    }
}
