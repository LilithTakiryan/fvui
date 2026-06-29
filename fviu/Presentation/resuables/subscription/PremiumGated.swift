//
//  PremiumGated.swift
//  fviu
//
//  Created by lilit on 29.06.26.
//

import SwiftUI

struct PremiumGated: ViewModifier {
    @EnvironmentObject var subManager: SubscriptionManager
    /// Pass a binding from the parent to trigger navigation
    @Binding var showPaywall: Bool
    
    func body(content: Content) -> some View {
        if subManager.hasPremium {
            content
        } else {
            content
                .disabled(true)
                .overlay(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showPaywall = true
                        }
                )
        }
    }
}

extension View {
    func premiumGated(showPaywall: Binding<Bool>) -> some View {
        self.modifier(PremiumGated(showPaywall: showPaywall))
    }
}
