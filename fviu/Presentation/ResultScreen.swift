//
//  ResultScreen.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

#Preview {
    ResultScreen()
}

struct ResultScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { /* Back action */ }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Result")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            GeometryReader { geometry in
                Image(.default)
                    .resizable()
                    .aspectRatio(9/16, contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(alignment: .topTrailing) {
                        ReplaceButton(action: {})
                    }
            }
            .aspectRatio(9/16, contentMode: .fit)
            .padding(.horizontal, 16) 
            HStack(spacing: 12) {
                Button("Share") { }
                    .buttonStyle(CustomCapsuleButtonStyle(
                        background: ChatChatUIConfig.Colors.receiverBubbleBg,
                        verticalPadding: ChatChatUIConfig.Sizes.mainButtonVerticalPadding + 4
                    ))
                
                Button("Download") { }
                    .buttonStyle(CustomCapsuleButtonStyle(
                        background: ChatChatUIConfig.Colors.brandGradient,
                        verticalPadding: ChatChatUIConfig.Sizes.mainButtonVerticalPadding,
                        isScaled: true
                    ))
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.vertical)
        .background(Color.black.ignoresSafeArea())
    }
}
