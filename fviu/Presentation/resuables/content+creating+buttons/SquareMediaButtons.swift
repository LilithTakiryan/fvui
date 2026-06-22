//
//  SquareMediaButtons.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

struct GradientBorderPlusButton: View {
    enum ButtonState {
        case empty
        case loading
        case filled(image: Image)
    }

    let state: ButtonState
    let action: () -> Void
    var onRemove: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                switch state {
                case .empty:
                    Button(action: action) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: ChatChatUIConfig.SquareButton.size, height: ChatChatUIConfig.SquareButton.size)
                    }
                    .background(ChatChatUIConfig.Colors.receiverBubbleBg)
                    .clipShape(RoundedRectangle(cornerRadius: ChatChatUIConfig.SquareButton.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: ChatChatUIConfig.SquareButton.cornerRadius)
                            .stroke(
                                ChatChatUIConfig.Colors.brandGradient,
                                lineWidth: ChatChatUIConfig.SquareButton.borderLineWidth
                            )
                    )

                case .loading:
                    ZStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                    .frame(width: ChatChatUIConfig.SquareButton.size, height: ChatChatUIConfig.SquareButton.size)
                    .background(ChatChatUIConfig.Colors.receiverBubbleBg)
                    .clipShape(RoundedRectangle(cornerRadius: ChatChatUIConfig.SquareButton.cornerRadius))

                case let .filled(image):
                    Button(action: action) {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: ChatChatUIConfig.SquareButton.size, height: ChatChatUIConfig.SquareButton.size)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: ChatChatUIConfig.SquareButton.cornerRadius))
                }
            }

            if case .filled = state {
                Button(action: { onRemove?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ChatChatUIConfig.Colors.brandGradient)
                        .frame(width: 22, height: 22)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 1)
                }
                .offset(x: 6, y: -6)
            }
        }
        .frame(width: ChatChatUIConfig.SquareButton.size + 12, height: ChatChatUIConfig.SquareButton.size + 12)
    }
}

struct ReplaceButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Replace")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .padding(16)
    }
}

struct GradientBorderPlusButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ChatChatUIConfig.Colors.backgroundDeep.ignoresSafeArea()

            VStack(spacing: 40) {
                ReplaceButton(action: {
                    print("Replace tapped")
                })
                VStack(spacing: 8) {
                    Text("Empty State")
                        .font(.caption)
                        .foregroundColor(.gray)
                    GradientBorderPlusButton(state: .empty, action: {})
                }

                VStack(spacing: 8) {
                    Text("Loading State")
                        .font(.caption)
                        .foregroundColor(.gray)
                    GradientBorderPlusButton(state: .loading, action: {})
                }

                VStack(spacing: 8) {
                    Text("Filled State")
                        .font(.caption)
                        .foregroundColor(.gray)
                    GradientBorderPlusButton(
                        state: .filled(image: Image(systemName: "person.crop.rectangle.stack.fill")),
                        action: {},
                        onRemove: {}
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
