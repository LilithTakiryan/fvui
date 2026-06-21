//
//  GradientText.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import SwiftUI

struct GradientText: View {
    var text: String
    var font: Font = .system(size: 32, weight: .bold, design: .default)

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(.clear)
            .background(
                ChatChatUIConfig.Colors.brandGradient
            )
            .mask(
                Text(text).font(font)
            )
    }
}

#Preview {
    GradientText(
        text: "Welcome to the team, Alexander!"
    )
}
