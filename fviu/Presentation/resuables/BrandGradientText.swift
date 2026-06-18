//
//  BrandGradientText.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//

import SwiftUI

struct GradientText: View {
    let text: String
    let font: Font = .system(size: 32, weight: .bold, design: .default)
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(.clear)
            .background(
                ChatUIConfig.Colors.brandGradient
            )
            .mask(
                Text(text).font(font)
            )
            .kerning(0.5)
    }
}

#Preview {
    GradientText(
        text: "Welcome to the team, Alexander!"
    )
}


