//
//  SendMessageUseCase 2.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//


struct SendMessageUseCase {
    private let repo: ChatRepository
    
    init(repo: ChatRepository) {
        self.repo = repo
    }
    
    func execute(chatID: String, text: String) async throws -> String {
        try await repo.send(chatID: chatID, text: text)
    }
}
