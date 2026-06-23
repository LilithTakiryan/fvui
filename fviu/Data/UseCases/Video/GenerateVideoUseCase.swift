//
//  GenerateVideoUseCase.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct GenerateVideoUseCase {
    private let repo: VideoRepository

    init(repo: VideoRepository) {
        self.repo = repo
    }

    func execute(prompt: String) async throws -> Int {
        try await repo.generate(prompt: prompt)
    }
}
