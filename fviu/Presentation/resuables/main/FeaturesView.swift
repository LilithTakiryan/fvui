//
//  FeatureFixWritingButton.swift
//  fviu
//
//  Created by lilit on 23.06.26.
//
import SwiftUI

struct FeatureFixWritingButton: View {
    let action: () -> Void
    var body: some View {
        ReusableMenuButton(
            action: action,
            systemIcon: .edit2,
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

struct FeaturesView: View {
    let generateAction: () -> Void
    let fixAction: () -> Void
    let summarizeAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            MainScreenMenu(action: generateAction)
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
