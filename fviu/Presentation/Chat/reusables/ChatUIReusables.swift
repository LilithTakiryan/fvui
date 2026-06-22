//
//  ChatUIReusables.swift
//  fviu
//
//  Created by lilit on 18.06.26.
//

import SwiftUI

#Preview {
    VStack(spacing: 24) {
        OpenChatButton(action: {})
        ChatHistoryItem(action: {}, summary: "Summary title texting longe text to see how it wraps and looks", time: "13:45 AM")
        CustomConstants.Colors.backgroundDeep.ignoresSafeArea()
        ReceiverChatBubble(messageText: "hi")
        GradientChatBubble(text: "hi")
        TypingIndicatorView()
    }
}

struct CustomCapsuleButtonStyle: ButtonStyle {
    var background: AnyShapeStyle
    var verticalPadding: CGFloat
    var isScaled: Bool = false

    init<S: ShapeStyle>(background: S, verticalPadding: CGFloat, isScaled: Bool = false) {
        self.background = AnyShapeStyle(background)
        self.verticalPadding = verticalPadding
        self.isScaled = isScaled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: CustomConstants.Sizes.mainButtonFontSize, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .background(Capsule().fill(background))
            .opacity(isScaled ? 1.0 : (configuration.isPressed ? 0.7 : 1.0))
            .scaleEffect(isScaled && configuration.isPressed ? 0.98 : 1.0)
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
            cornerRadii: CGSize(width: CustomConstants.CornerRadii.defaultBubbleRadius, height: CustomConstants.CornerRadii.defaultBubbleRadius)
        )
        return Path(path.cgPath)
    }
}

struct GradientChatBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: CustomConstants.Sizes.bubbleFontSize, weight: .regular))
            .foregroundColor(.white)
            .lineSpacing(CustomConstants.Sizes.bubbleLineSpacing)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(CustomConstants.Colors.brandGradient)
            .clipShape(ChatBubbleShape(isFromCurrentUser: true))
            .frame(maxWidth: CustomConstants.Sizes.maxBubbleWidth, alignment: .trailing)
    }
}

struct ReceiverChatBubble: View {
    let messageText: String

    var body: some View {
        Text(messageText)
            .font(.system(size: CustomConstants.Sizes.bubbleFontSize, weight: .regular))
            .foregroundColor(.white)
            .lineSpacing(CustomConstants.Sizes.bubbleLineSpacing)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(CustomConstants.Colors.receiverBubbleBg)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: CustomConstants.CornerRadii.defaultBubbleRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: CustomConstants.CornerRadii.defaultBubbleRadius,
                    topTrailingRadius: CustomConstants.CornerRadii.defaultBubbleRadius
                )
            )
            .frame(maxWidth: CustomConstants.Sizes.maxBubbleWidth, alignment: .leading)
    }
}

struct TypingIndicatorView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .fill(CustomConstants.Colors.brandGradient)
                .frame(width: CustomConstants.Sizes.indicatorDotLarge, height: CustomConstants.Sizes.indicatorDotLarge)
                .scaleEffect(isAnimating ? 1.15 : 0.85)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0), value: isAnimating)

            Circle()
                .fill(CustomConstants.Colors.inactiveDotBg)
                .frame(width: CustomConstants.Sizes.indicatorDotMedium, height: CustomConstants.Sizes.indicatorDotMedium)
                .scaleEffect(isAnimating ? 1.15 : 0.85)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.15), value: isAnimating)

            Circle()
                .fill(CustomConstants.Colors.inactiveDotBg)
                .frame(width: CustomConstants.Sizes.indicatorDotSmall, height: CustomConstants.Sizes.indicatorDotSmall)
                .scaleEffect(isAnimating ? 1.15 : 0.85)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: isAnimating)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(CustomConstants.Colors.receiverBubbleBg)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: CustomConstants.CornerRadii.indicatorBubbleRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: CustomConstants.CornerRadii.indicatorBubbleRadius,
                topTrailingRadius: CustomConstants.CornerRadii.indicatorBubbleRadius
            )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

extension View {
    func brandCardStyle(cornerRadius: CGFloat = 20, isSelected: Bool = true) -> some View {
        background(Color(red: 0.05, green: 0.05, blue: 0.07))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected ? CustomConstants.Colors.brandGradient : LinearGradient(colors: [CustomConstants.Paywall.inactiveBorderColor], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 2
                    )
            )
    }
}

import SwiftUI

struct OpenChatButton: View {
    var action: () -> Void

    var body: some View {
        ZStack {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .medium))

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
                                    Color.pink.opacity(0.3),
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

struct ChatHistoryItem: View {
    var action: () -> Void
    var summary: String
    var time: String
    var body: some View {
        HStack(spacing: 12) {
            Image(.twoSparkles)
                .font(.system(size: 20, weight: .medium))

            VStack(alignment: .leading, spacing: 4) {
                Text(summary)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(time)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.1, green: 0.08, blue: 0.12))
        )
        .padding(.horizontal, 16)
    }
}
