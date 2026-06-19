//
//  EmptyChatView.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

#Preview {
    VStack(spacing: 30){
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
        VStack{
            Image(icon)
                .frame(width: 60, height: 60)
            Text(title)
                .font(.system(size: 28))
                .foregroundColor(.white)
            Text(description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
        }
        
    }
}


struct EmptyChatView: View {
    var body: some View {
        VStack() {
            VStack() {
                HStack() {
                    Text("Your")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    GradientText(
                        text: "AI assistant",
                        font: .system(size: 24, weight: .bold, design: .default)
                    )
                }
                Text("for anything.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Ask questions, get answers, and explore ideas in seconds")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}


