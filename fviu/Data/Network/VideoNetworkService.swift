//
//  VideoNetworkService.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

import Foundation

protocol VideoNetworkService: Sendable {
    func generateVideoFromText(prompt: String) async throws -> Int
    func getStatus(videoID: Int) async throws -> Text2VideoStatusResponse
    func getTemplates() async throws -> [VideoTemplateResponse]
    func template2video( templateId: Int, imageData: Data, duration: Int?, quality: String?) async throws -> Int
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
        let result = try await api.request(Text2VideoEndpoint.generate(prompt), response: VideoGenerationResponse.self)
        print("videoID: \(result.videoId)")
        return result.videoId
    }
    
    struct ApiEnvelope<T: Decodable>: Decodable {
        let data: T
    }

    func getTemplates() async throws -> [VideoTemplateResponse] {
        do {
            let response = try await api.request(
                Text2VideoEndpoint.getTemplates,
                response: VideoTemplatesContainerResponse.self
            )
            return response.templates
        } catch {
            print("Template decode failed: \(error)")
            throw error
        }
    }
    
    func template2video( templateId: Int, imageData: Data, duration: Int?, quality: String?) async throws -> Int {
        do {
            let response = try await api.request(
                Text2VideoEndpoint.template2video( templateId: templateId, imageData: imageData, duration: duration, quality: quality),
                response: VideoGenerationResponse.self
            )
            print("network: \(response.videoId)")
            return response.videoId
        } catch {
            print("Template 2 video failed: \(error)")
            throw error
        }
    }
}

