//
//  ChatNetworkService.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//


protocol ChatNetworkService: Sendable {
    func sendMessage(_ text: String, chatID: String) async throws -> String
    func fetchMessages(chatID: String) async throws -> [ChatMessage]
    func fetchChats() async throws -> [DolaChatItem]
}

final class DolaNetworkService: ChatNetworkService {
    private let api: APIClientProtocol

        init(api: APIClientProtocol = APIClient(tokenProvider: .bearer)) {
            self.api = api
        }

    func sendMessage(_ text: String, chatID: String) async throws -> String {
        let payload = try await api.request(ChatEndpoint.send(chatID: chatID, text: text), response: [String: String].self)
        return payload["assistant_message"] ?? "No response"
    }

    func fetchChats() async throws -> [DolaChatItem] {
        try await api.request(ChatEndpoint.chats(limit: 50), response: [DolaChatItem].self)
    }

    func fetchMessages(chatID: String) async throws -> [ChatMessage] {
        let items = try await api.request(ChatEndpoint.messages(chatID: chatID, limit: 50), response: [DolaMessageItem].self)
        return items.map { ChatMessage(text: $0.content, isFromCurrentUser: $0.role == "user") }
    }
}
