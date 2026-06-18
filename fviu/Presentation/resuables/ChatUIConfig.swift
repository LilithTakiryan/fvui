//
//  ChatUIConfig.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//


import SwiftUI

enum ChatUIConfig {
    enum Paywall {
        static let cardCornerRadius: CGFloat = 24
        static let cardBorderWidth: CGFloat = 2
        static let inactiveBorderColor = Color(red: 0.16, green: 0.16, blue: 0.18)
        static let subTextColor = Color(red: 0.4, green: 0.4, blue: 0.4)
    }
    enum Colors {
        static let backgroundDeep = Color.black
        static let receiverBubbleBg = Color(red: 0.12, green: 0.12, blue: 0.14)
        static let inactiveDotBg = Color(red: 0.2, green: 0.2, blue: 0.2)
        
        static let brandGradient = LinearGradient(
            colors: [
                Color(red: 0.58, green: 0.78, blue: 1.0),
                Color(red: 0.74, green: 0.62, blue: 0.86),
                Color(red: 0.94, green: 0.42, blue: 0.61)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    enum SquareButton {
        static let size: CGFloat = 56
        static let cornerRadius: CGFloat = 16
        static let borderLineWidth: CGFloat = 2 
    }
    
    enum Sizes {
        static let mainButtonVerticalPadding: CGFloat = 16
        static let mainButtonFontSize: CGFloat = 17
        
        static let bubbleFontSize: CGFloat = 16
        static let bubbleLineSpacing: CGFloat = 4
        static let maxBubbleWidth: CGFloat = 280
        
        static let indicatorDotLarge: CGFloat = 30
        static let indicatorDotMedium: CGFloat = 18
        static let indicatorDotSmall: CGFloat = 12
    }
    
    enum CornerRadii {
        static let defaultBubbleRadius: CGFloat = 20
        static let indicatorBubbleRadius: CGFloat = 24
    }
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: ChatUIConfig.Sizes.mainButtonFontSize, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, ChatUIConfig.Sizes.mainButtonVerticalPadding)
            .frame(maxWidth: .infinity)
            .background(ChatUIConfig.Colors.brandGradient)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ChatBubbleShape: Shape {
    var isFromCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromCurrentUser ?
            [.topLeft, .topRight, .bottomLeft] :
                [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: ChatUIConfig.CornerRadii.defaultBubbleRadius, height: ChatUIConfig.CornerRadii.defaultBubbleRadius)
        )
        return Path(path.cgPath)
    }
}

struct GradientChatBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: ChatUIConfig.Sizes.bubbleFontSize, weight: .regular))
            .foregroundColor(.white)
            .lineSpacing(ChatUIConfig.Sizes.bubbleLineSpacing)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(ChatUIConfig.Colors.brandGradient)
            .clipShape(ChatBubbleShape(isFromCurrentUser: true))
            .frame(maxWidth: ChatUIConfig.Sizes.maxBubbleWidth, alignment: .trailing)
    }
}

struct ReceiverChatBubble: View {
    let messageText: String
    
    var body: some View {
        Text(messageText)
            .font(.system(size: ChatUIConfig.Sizes.bubbleFontSize, weight: .regular))
            .foregroundColor(.white)
            .lineSpacing(ChatUIConfig.Sizes.bubbleLineSpacing)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(ChatUIConfig.Colors.receiverBubbleBg)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: ChatUIConfig.CornerRadii.defaultBubbleRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: ChatUIConfig.CornerRadii.defaultBubbleRadius,
                    topTrailingRadius: ChatUIConfig.CornerRadii.defaultBubbleRadius
                )
            )
            .frame(maxWidth: ChatUIConfig.Sizes.maxBubbleWidth, alignment: .leading)
    }
}

struct TypingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .fill(ChatUIConfig.Colors.brandGradient)
                .frame(width: ChatUIConfig.Sizes.indicatorDotLarge, height: ChatUIConfig.Sizes.indicatorDotLarge)
                .scaleEffect(isAnimating ? 1.15 : 0.85)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0), value: isAnimating)
            
            Circle()
                .fill(ChatUIConfig.Colors.inactiveDotBg)
                .frame(width: ChatUIConfig.Sizes.indicatorDotMedium, height: ChatUIConfig.Sizes.indicatorDotMedium)
                .scaleEffect(isAnimating ? 1.15 : 0.85)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.15), value: isAnimating)
            
            Circle()
                .fill(ChatUIConfig.Colors.inactiveDotBg)
                .frame(width: ChatUIConfig.Sizes.indicatorDotSmall, height: ChatUIConfig.Sizes.indicatorDotSmall)
                .scaleEffect(isAnimating ? 1.15 : 0.85)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: isAnimating)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(ChatUIConfig.Colors.receiverBubbleBg)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: ChatUIConfig.CornerRadii.indicatorBubbleRadius,
                bottomLeadingRadius: 0, 
                bottomTrailingRadius: ChatUIConfig.CornerRadii.indicatorBubbleRadius,
                topTrailingRadius: ChatUIConfig.CornerRadii.indicatorBubbleRadius
            )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        ChatUIConfig.Colors.backgroundDeep.ignoresSafeArea()
        
        VStack(spacing: 24) {
            
            VStack(spacing: 16) {
                HStack {
                    ReceiverChatBubble(messageText: "hi")
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    GradientChatBubble(text: "hi")
                }
                
                HStack {
                    TypingIndicatorView()
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
