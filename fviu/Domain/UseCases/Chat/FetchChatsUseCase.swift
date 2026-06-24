//
//  FetchChatsUseCase.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct FetchChatsUseCase {
    private let repo: IChatRepository

    init(repo: IChatRepository) {
        self.repo = repo
    }

    func execute() async throws -> [DolaChatItem] {
        try await repo.chats()
    }
}
