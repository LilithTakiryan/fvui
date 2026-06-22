//
//  ChatBottomInputField.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

struct ChatBottomInputField: View {
    @State private var inputText: String = ""
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        Color.black
            .ignoresSafeArea()
            .sheet(isPresented: $viewModel.showBottomSheet) {
                VStack {
                    HStack(alignment: .bottom) {
                        TextField("How can I help you?", text: $inputText, axis: .vertical)
                            .lineLimit(1 ... 5)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)

                        HStack(spacing: 12) {
                            if inputText.isEmpty {
                                Image(systemName: "arrow.down.circle")
                                    .font(.title2)
                                    .foregroundColor(.gray)

                                Image(systemName: "mic.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            } else {
                                Button(action: sendMessage) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Circle().fill(ChatChatUIConfig.Colors.brandGradient))
                                }
                                .disabled(viewModel.isAiThinking)
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, inputText.isEmpty ? 12 : 6)
                    }
                    .background(ChatChatUIConfig.Dropdown.buttonBackground)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer()
                }
                .presentationDetents([.height(115)])
                .presentationBackground(ChatChatUIConfig.Dropdown.buttonBackground)
                .presentationBackgroundInteraction(
                    .enabled(upThrough: .height(115))
                )
                .interactiveDismissDisabled()
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
    }

    private func sendMessage() {
        Task {
            await viewModel.sendMessage(inputText)
            inputText = ""
        }
    }
}
