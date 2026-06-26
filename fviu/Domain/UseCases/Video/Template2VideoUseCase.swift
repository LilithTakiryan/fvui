//
//  Template2VideoUseCase.swift
//  fviu
//
//  Created by lilit on 26.06.26.
//

import Foundation


struct Template2VideoUseCase {
    private let repo: IText2VideoRepository

    init(repo: IText2VideoRepository) {
        self.repo = repo
    }

    func execute(
                 templateId: Int,
                 imageData: Data,
                 duration: Int?,
                 quality: String?) async throws -> Int {
        try await repo
            .template2video(
                templateId: templateId,
                imageData: imageData,
                duration: duration,
                quality: quality
            )
    }
}
