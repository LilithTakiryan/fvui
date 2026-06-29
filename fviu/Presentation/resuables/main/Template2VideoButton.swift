//
//  MainScreenMenu.swift
//  fviu
//
//  Created by lilit on 20.06.26.
//

import SwiftUI

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FeaturesView(
            generateAction: {},
            fixAction: {},
            summarizeAction: {}
        )
        .padding()
    }
}

struct Template2VideoButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(.image)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())

                Text("Turn Photo\ninto Video")
                    .font(CustomConstants.Typography.medium20)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Text("Animate • Templates")
                    .font(CustomConstants.Typography.regular14)
                    .foregroundColor(.white.opacity(0.7))

                Spacer(minLength: 24)

                HStack(alignment: .center, spacing: 8) {
                    Text("Ready in seconds")
                        .font(CustomConstants.Typography.regular12)
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8.5)
                .background(.white.opacity(0.2), in: Capsule())
            }
            .padding(11.5)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background {
                Image(.generateVideo)
                    .resizable()
            }
            .clipShape(RoundedRectangle(cornerRadius: CustomConstants.CornerRadius.radius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
