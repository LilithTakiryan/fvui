//
//  CustomSearchButton.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//

import SwiftUI


struct OpenChatButton: View {
    var action: () -> Void
    
    var body: some View {
        ZStack {
           
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Ask anything...")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color(red: 0.1, green: 0.08, blue: 0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.4),
                                    Color.purple.opacity(0.4),
                                    Color.pink.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
        }
    }
}

#Preview {
    OpenChatButton(action: {
        print("Button tapped")
    })
}
