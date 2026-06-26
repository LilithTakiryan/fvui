//
//  GenerateVideoUseCase.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Foundation

struct GenerateVideoFromTextUseCase {
    private let repo: IText2VideoRepository

    init(repo: IText2VideoRepository) {
        self.repo = repo
    }

    func execute(prompt: String) async throws -> Int {
        try await repo.generate(prompt: prompt)
    }
}
