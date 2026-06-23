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
    @StateObject private var viewModel = DependencyContainer.shared.makeChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                ScrollView {
                    if !viewModel.messages.isEmpty {
                        ChatContentListView(viewModel: viewModel)
                    }
                }
                
                ChatBottomInputField(viewModel: viewModel)
            }
            
            
            if viewModel.messages.isEmpty {
                EmptyChatView()
                    .padding(.horizontal, 16)
                
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
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
                        
                        Text(Date().formatted(
                            .dateTime
                                .day(.twoDigits)
                                .month(.twoDigits)
                                .year(.defaultDigits)
                                .locale(Locale(identifier: "de_DE"))
                        ))
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ChatHistoryScreen(viewModel: viewModel)) {
                    Image(.history)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            viewModel.showBottomSheet = true
            viewModel.initializeChat(chatID: "test-chat-id")
            viewModel.showBottomSheet = true
        }
        .onDisappear {
            viewModel.cleanChat()
            viewModel.showBottomSheet = false
        }
        .environmentObject(viewModel)
    }
}
