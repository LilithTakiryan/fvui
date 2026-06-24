//
//  ReusableMenuButton.swift
//  fviu
//
//  Created by lilit on 23.06.26.
//

import SwiftUI

#Preview {
    ReusableMenuButton(
        action: {},
        systemIcon: .text,
        title: "Understand\nFaster",
        description: "Summarize • Key points"
    )
}

struct ReusableMenuButton: View {
    let action: () -> Void
    let systemIcon: ImageResource
    let title: String
    let description: String

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemIcon)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())

                Spacer(minLength: 8)

                Text(title)
                    .font(CustomConstants.Typography.medium16)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(description)
                    .font(CustomConstants.Typography.medium12)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(CustomConstants.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
