//
//  PaywallScreen.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//

import SwiftUI

struct PaywallScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var options = [
        SubscriptionOption(duration: "Year", weeklyPrice: "$1.27", fullPrice: "$69.99", discountBadge: "SAVE 80%"),
        SubscriptionOption(duration: "Month", weeklyPrice: "$1.99", fullPrice: "$7.99", discountBadge: nil)
    ]
    
    @State private var selectedId: UUID?
    @State private var showButton = false
    var body: some View {
            ZStack {
                ChatUIConfig.Colors.backgroundDeep.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    headerSection
                    featuresList
                    cardsSection
                    cancelIndicator
                    actionButton
                    footerLinks
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if showButton {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
            }
            .onAppear {
                if selectedId == nil {
                    selectedId = options.first?.id
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showButton = true
                    }
                }
            }
        }
    
    @ViewBuilder
    private var headerSection: some View {
        Text("Create anything you want")
            .foregroundColor(.white)
            .font(.system(size: 34, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
    
    
    
    @ViewBuilder
    private var cardsSection: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                subscriptionCard(for: option)
            }
        }
    }
    
    @ViewBuilder
    private func subscriptionCard(for option: SubscriptionOption) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(option.duration)
                        .font(.system(size: 20, weight: .bold))
                    Text("\(option.weeklyPrice) / week")
                        .font(.system(size: 20, weight: .medium))
                }
                .foregroundColor(.white)
                
                Text(option.fullPrice)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ChatUIConfig.Paywall.subTextColor)
            }
            
            Spacer()
            
            if let badgeText = option.discountBadge {
                Text(badgeText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(ChatUIConfig.Colors.brandGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .brandCardStyle(cornerRadius: 24, isSelected: selectedId == option.id)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedId = option.id
            }
        }
    }
    
    @ViewBuilder
    private var cancelIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
            Text("Cancel anytime")
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(ChatUIConfig.Paywall.subTextColor)
    }
    
    @ViewBuilder
    private var actionButton: some View {
        Button(action: { print("Purchase triggered for: \(String(describing: selectedId))") }) {
            Text("Unlock now")
        }
        .buttonStyle(GradientButtonStyle())
    }
    
    @ViewBuilder
    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(icon: .sparkle, title: "Get results in seconds")
            featureRow(icon: .edit, title: "Turn any text into better writing")
            featureRow(icon: .text, title: "Simplify complex information")
            featureRow(icon: .image, title: "Create content with AI templates")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var footerLinks: some View {
        HStack {
            Text("Privacy policy")
            Spacer()
            Text("Restore purchases")
            Spacer()
            Text("Terms of use")
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(ChatUIConfig.Paywall.subTextColor)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private func featureRow(icon: ImageResource, title: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
}

#Preview {
    PaywallScreen()
}
