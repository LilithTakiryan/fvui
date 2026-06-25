//
//  VideoNetworkService.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

protocol VideoNetworkService: Sendable {
    func generateVideoFromText(prompt: String) async throws -> Int
    func getStatus(videoID: Int) async throws -> Text2VideoStatusResponse
    func getTemplates() async throws -> [VideoTemplateResponse]
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
        print("videoID: \(result.videoId)")
        return result.videoId
    }
    
    // 1. Create a generic envelope wrapper
    struct ApiEnvelope<T: Decodable>: Decodable {
        let data: T
    }

    // 2. Update your function to decode through the envelope
    func getTemplates() async throws -> [VideoTemplateResponse] {
        do {
            let response = try await api.request(
                Text2VideoEndpoint.template,
                response: VideoTemplatesContainerResponse.self
            )
            return response.templates
        } catch {
            print("Template decode failed: \(error)")
            throw error
        }
    }
}

