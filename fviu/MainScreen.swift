//
//  ContentView.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//

import SwiftUI

#Preview {
    MainScreen()
}

struct MainScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                Image(.bg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Image(.sparkles)
                        .frame(width: 60, height: 60)
                    Text("Your AI tools ready to go")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    OpenChatButton(action: {
                        print("Button tapped")
                    })
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
        }
    }
}




