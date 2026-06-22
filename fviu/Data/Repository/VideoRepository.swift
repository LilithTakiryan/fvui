//
//  VideoRepository.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//


protocol VideoRepository {
    func generate(prompt: String) async throws -> Int
    func status(id: Int) async throws -> VideoStatusResponse
}

final class VideoRepositoryImpl: VideoRepository {
    private let service: VideoNetworkService
    init(service: VideoNetworkService) { self.service = service }

    func generate(prompt: String) async throws -> Int { try await service.generateVideo(prompt: prompt) }
    func status(id: Int) async throws -> VideoStatusResponse { try await service.getStatus(videoID: id) }
}