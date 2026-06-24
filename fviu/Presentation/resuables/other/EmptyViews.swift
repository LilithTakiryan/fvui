//
//  EmptyViews.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

#Preview {
    VStack(spacing: 30) {
        NoContentYet(icon: .edit, title: "No chats yet", description: "Start a conversation to see your history here")
        NoContentYet(icon: .image, title: "No videos yet", description: "Create your first video to see it here")
        EmptyChatView()
    }
}

struct NoContentYet: View {
    let icon: ImageResource
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Image(icon)
                .frame(width: 60, height: 60)
            Text(title)
                .font(CustomConstants.Typography.bold28)
                .foregroundColor(.white)
            Text(description)
                .font(CustomConstants.Typography.regular16)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

struct EmptyChatView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Text("Your")
                    .font(CustomConstants.Typography.bold24)
                    .foregroundColor(.white)
                GradientText(
                    text: "AI Assistant",
                    font: .system(size: 24, weight: .bold)
                ).font(CustomConstants.Typography.bold24)
                Text("for anything")
                    .font(CustomConstants.Typography.bold24)
                    .foregroundColor(.white)
            }

            Text("Ask questions, brainstorm ideas, write content, or get instant answers.")
                .font(CustomConstants.Typography.regular14)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
