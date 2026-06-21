//
//  GenerateVideoView.swift
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

struct FeaturesView: View {
    let generateAction: () -> Void
    let fixAction: () -> Void
    let summarizeAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            GenerateVideoView(action: generateAction)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 12) {
                FeatureFixWritingButton(action: fixAction)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                FeatureUnderstandFasterButton(action: summarizeAction)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct FeatureFixWritingButton: View {
    let action: () -> Void
    var body: some View {
        ReusableMenuButton(
            action: action,
            systemIcon: .edit,
            title: "Fix & Improve\nWriting",
            description: "Rewrite • Fix grammar"
        )
    }
}

struct FeatureUnderstandFasterButton: View {
    let action: () -> Void
    var body: some View {
        ReusableMenuButton(
            action: action,
            systemIcon: .text,
            title: "Understand\nFaster",
            description: "Summarize • Key points"
        )
    }
}

struct GenerateVideoView: View {
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
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Text("Animate • Templates")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))

                Spacer(minLength: 24)

                HStack(spacing: 6) {
                    Text("Ready in seconds")
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background {
                Image(.generateVideo)
                    .resizable()
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }
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
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())

                Spacer(minLength: 8)

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color(red: 0.1, green: 0.1, blue: 0.13))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
