//
//  ChatRepository.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

final class ChatRepositoryImpl: IChatRepository {
    private let service: ChatNetworkService
    init(service: ChatNetworkService) {
        self.service = service
    }

    func chats() async throws -> [DolaChatItem] {
        try await service.fetchChats()
    }

    func messages(chatID: String) async throws -> [ChatMessage] {
        try await service.fetchMessages(chatID: chatID)
    }

    func send(chatID: String, text: String) async throws -> String {
        try await service.sendMessage(text, chatID: chatID)
    }
}
