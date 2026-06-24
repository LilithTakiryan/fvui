//
//  GetVideoStatusUseCase.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct GetVideoStatusUseCase {
    private let repo: IText2VideoRepository

    init(repo: IText2VideoRepository) {
        self.repo = repo
    }

    func execute(id: Int) async throws -> Text2VideoStatusResponse {
        try await repo.status(id: id)
    }
}
