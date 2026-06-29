//
//  MainScreen.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//

import SwiftUI

#Preview {
    MainScreen()
}

struct MainScreen: View {
    @State private var navigateToChat = false
    @State private var navigateToGenerate = false
    @State private var showPaywallScreen = false
    @State private var showOneTimePaywall: Bool = true
    @EnvironmentObject var subManager: SubscriptionManager
    

    fileprivate func MainScreenContent() -> VStack<TupleView<(VStack<TupleView<(some View, some View, some View)>>, some View)>> {
        return VStack(spacing: 40) {
            VStack(spacing: 24) {
                Image(.sparkles)
                    .frame(width: 60, height: 60)
                Text(.labelMainTools)
                    .foregroundColor(.white)
                    .font(CustomConstants.Typography.bold24)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                OpenChatButton(action: {
                    navigateToChat = true
                })
                .navigationDestination(isPresented: $navigateToChat) {
                    ChatScreen()
                }
                .navigationDestination(isPresented: $navigateToGenerate) {
                    TemplatesScreen()
                }
            }
            
            FeaturesView(
                generateAction: { navigateToGenerate = true },
                fixAction: { navigateToChat = true },
                summarizeAction: { navigateToChat = true }
            )
            .premiumGated(showPaywall: $showPaywallScreen)
            .padding()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                Image(.bg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                MainScreenContent()
                    .onAppear {
                        if !subManager.hasPremium && showOneTimePaywall   {
                            Task {
                                // Delays for 1.5 seconds
                                try? await Task.sleep(nanoseconds: 1_500_000_000)
                                
                                await MainActor.run {
                                    showPaywallScreen = true
                                    showOneTimePaywall = false
                                }
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: PaywallScreen()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationDestination(
                isPresented: $showPaywallScreen){ PaywallScreen()
                }
        }
    }
}
