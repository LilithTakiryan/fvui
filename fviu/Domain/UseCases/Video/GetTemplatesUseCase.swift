//
//  GetTemplatesUseCase.swift
//  fviu
//
//  Created by lilit on 25.06.26.
//




struct GetTemplatesUseCase {
    private let repo: IText2VideoRepository

    init(repo: IText2VideoRepository) {
        self.repo = repo
    }

    func execute() async throws -> [VideoTemplateResponse] {
        try await repo.getTemplates()
    }
}
