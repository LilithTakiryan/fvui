//
//  VideoNetworkService.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//


protocol VideoNetworkService: Sendable {
    func generateVideo(prompt: String) async throws -> Int
    func getStatus(videoID: Int) async throws -> VideoStatusResponse
}

final class PixverseNetworkService: VideoNetworkService {

    private let api: APIClientProtocol

        init(api: APIClientProtocol = APIClient(tokenProvider: .bearer)) {
            self.api = api
        }

    func getStatus(videoID: Int) async throws -> VideoStatusResponse {
        try await api.request(VideoEndpoint.status(videoID), response: VideoStatusResponse.self)
    }

    func generateVideo(prompt: String) async throws -> Int {
        let result = try await api.request(VideoEndpoint.generate(prompt), response: Text2VideoResponse.self)
        return result.video_id
    }
}
