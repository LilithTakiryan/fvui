//
//  ChatChatUIConfig 2.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import SwiftUI

enum ChatChatUIConfig {
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
                Color(red: 0.94, green: 0.42, blue: 0.61),
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

    enum Dropdown {
        static let panelBackground = Color(red: 0.08, green: 0.08, blue: 0.09)
        static let buttonBackground = Color(red: 0.12, green: 0.12, blue: 0.14)
        static let cornerRadius: CGFloat = 20
    }
}
