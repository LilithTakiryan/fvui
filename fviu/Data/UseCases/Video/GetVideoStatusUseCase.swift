//
//  GetVideoStatusUseCase.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct GetVideoStatusUseCase {
    private let repo: VideoRepository

    init(repo: VideoRepository) {
        self.repo = repo
    }

    func execute(id: Int) async throws -> VideoStatusResponse {
        try await repo.status(id: id)
    }
}
