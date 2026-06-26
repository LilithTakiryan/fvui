//
//  ChatHistoryScreen.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//

import SwiftUI

struct ChatHistoryScreen: View {
    @StateObject private var viewModel = DependencyContainer.shared.makeChatViewModel()
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoadingChats {
                ProgressView()
                    .tint(.white)
            } else if viewModel.chats.isEmpty {
                NoContentYet(icon: .edit, title: "No chats yet", description: "Start a conversation to see your history here")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(viewModel.groupedChats.keys.sorted(by: >), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(viewModel.dateLabel(date))
                                    .font(CustomConstants.Typography.semiBold20)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)

                                ForEach(
                                    viewModel.groupedChats[date] ?? [],
                                    id: \.chatId
                                ) { chat in
                                    chatHistoryRow(chat)
                                }


                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle("AI Chat History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.showBottomSheet = false
            Task {
                await viewModel.loadChats()
            }
        }
    }
    private func chatHistoryRow(_ chat: DolaChatItem) -> some View {
        NavigationLink(destination: ChatScreen()) {
            ChatHistoryItem(
                action: {},
                summary: chat.title ?? "Untitled Chat",
                time: viewModel.formatTime(chat.updatedAt)  
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

