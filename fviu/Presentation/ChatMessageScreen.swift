//
//  ChatMessage.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//


import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}

struct ChatScreenView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi!", isFromCurrentUser: true),
        ChatMessage(text: "Hi! ", isFromCurrentUser: false)
    ]
    
    @State private var isAiThinking = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages) { message in
                            if message.isFromCurrentUser {
                                
                                HStack {
                                    Spacer()
                                    GradientChatBubble(text: message.text)
                                }
                            } else {
                                HStack {
                                    ReceiverChatBubble(messageText: message.text)
                                    Spacer()
                                }
                            }
                        }
                        
                        if isAiThinking {
                            HStack {
                                TypingIndicatorView()
                                
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 24))
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ChatScreenView()
}
