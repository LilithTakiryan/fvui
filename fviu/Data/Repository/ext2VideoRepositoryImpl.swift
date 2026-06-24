//
//  VideoRepository.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

final class ext2VideoRepositoryImpl: IText2VideoRepository {
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
}
