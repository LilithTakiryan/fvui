//
//  IChatRepository.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

protocol IChatRepository {
    func chats() async throws -> [DolaChatItem]
    func messages(chatID: String) async throws -> [ChatMessage]
    func send(chatID: String, text: String) async throws -> String
}
