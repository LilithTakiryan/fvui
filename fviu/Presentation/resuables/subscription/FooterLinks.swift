//
//  FooterLinks.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

import SwiftUI

struct FooterLinks: View {
    @ObservedObject var subManager: SubscriptionManager

    var body: some View {
        HStack {
            Text("Privacy policy")
                .font(CustomConstants.Typography.spProDisplayRegular11)
            Spacer()
            Button(action: {
                Task {
                        await subManager.restorePurchases()
                    }
            }) {
                Text("Restore purchases")
                    .font(CustomConstants.Typography.spProDisplayRegular11)
            }
            Spacer()
            Text("Terms of use")
                .font(CustomConstants.Typography.spProDisplayRegular11)
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(CustomConstants.Paywall.subTextColor)
        .padding(.horizontal, 10)
    }
}
