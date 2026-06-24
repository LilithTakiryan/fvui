//
//  VideoNetworkService.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

protocol VideoNetworkService: Sendable {
    func generateVideoFromText(prompt: String) async throws -> Int
    func getStatus(videoID: Int) async throws -> Text2VideoStatusResponse
}

final class PixverseNetworkService: VideoNetworkService {
    private let api: IAPIClient

    init(api: IAPIClient = APIClient(tokenProvider: .bearer)) {
        self.api = api
    }

    func getStatus(videoID: Int) async throws -> Text2VideoStatusResponse {
        try await api.request(Text2VideoEndpoint.status(videoID), response: Text2VideoStatusResponse.self)
    }

    func generateVideoFromText(prompt: String) async throws -> Int {
        let result = try await api.request(Text2VideoEndpoint.generate(prompt), response: Text2VideoResponse.self)
        return result.video_id
    }
}
