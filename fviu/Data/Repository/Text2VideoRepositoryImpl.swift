//
//  VideoRepository.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Foundation

final class Text2VideoRepositoryImpl: IText2VideoRepository {
    private let service: VideoNetworkService
    init(service: VideoNetworkService) {
        self.service = service
    }

    func generate(prompt: String) async throws -> Int {
        try await service.generateVideoFromText(prompt: prompt)
    }

    func status(id: Int) async throws -> Text2VideoStatusResponse {
        try await service.getStatus(videoID: id)
    }
    
    func getTemplates() async throws -> [VideoTemplateResponse] {
        try await service.getTemplates()
    }
    
    func template2video( templateId: Int, imageData: Data, duration: Int?, quality: String?) async throws -> Int {
        try await service
            .template2video(
                templateId: templateId,
                imageData: imageData,
                duration: duration,
                quality: quality
            )
    }
}
