//
//  ChatScreen.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import SwiftUI

#Preview {
    ChatScreen()
}

struct ChatScreen: View {
    @State private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    ShortChatInputView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color(red: 0.11, green: 0.09, blue: 0.13), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .principal) {
                HStack(spacing: 12) {
                    Image(.chatIcon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Chat")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(viewModel.customTodayString)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
              
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ChatHistoryScreen()) {
                    Image(.history)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

import SwiftUI
struct ShortChatInputView: View {
    @State private var inputText: String = ""
    @State private var showBottomSheet: Bool = true
    
    var body: some View {
        Color.black
            .ignoresSafeArea()
            .sheet(isPresented: $showBottomSheet) {
                VStack {
                    HStack(alignment: .bottom) {
                        TextField("How can I help you?", text: $inputText, axis: .vertical)
                            .lineLimit(1...5)
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
                                Button(action: { inputText = "" }) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Circle().fill(ChatChatUIConfig.Colors.brandGradient))
                                }
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
}
