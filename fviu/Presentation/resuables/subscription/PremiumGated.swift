//
//  PremiumGated.swift
//  fviu
//
//  Created by lilit on 29.06.26.
//

import SwiftUI

struct PremiumGated: ViewModifier {
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var showPaywall = false
    
    func body(content: Content) -> some View {
        if subManager.hasPremium {
            content
        } else {
            content
                .disabled(true)
                .onTapGesture {
                    showPaywall = true
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallScreen()
                        .environmentObject(subManager)
                }
        }
    }
}

extension View {
    func premiumGated() -> some View {
        self.modifier(PremiumGated())
    }
}
