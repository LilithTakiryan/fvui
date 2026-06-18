//
//  PlusButtonPressStyle.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//


import SwiftUI

extension View {
    func brandCardStyle(cornerRadius: CGFloat = 20, isSelected: Bool = true) -> some View {
        self
            .background(Color(red: 0.05, green: 0.05, blue: 0.07))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected ? ChatUIConfig.Colors.brandGradient : LinearGradient(colors: [ChatUIConfig.Paywall.inactiveBorderColor], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 2
                    )
            )
    }
}


struct GradientBorderPlusButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
        }
        .brandCardStyle(cornerRadius: 16, isSelected: true)
    }
}

#Preview {
    ZStack {
        ChatUIConfig.Colors.backgroundDeep.ignoresSafeArea()
        GradientBorderPlusButton {}
    }
}
