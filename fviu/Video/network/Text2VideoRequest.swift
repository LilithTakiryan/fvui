//
//  Text2VideoRequest.swift
//  fviu
//
//  Created by lilit on 21.06.26.
//

import Foundation

struct Text2VideoRequest: Codable {
    let prompt: String
    let duration: Int?
    let model: String?
    let quality: String?
    let aspect_ratio: String?

    enum CodingKeys: String, CodingKey {
        case prompt
        case duration
        case model
        case quality
        case aspect_ratio
    }
}

struct Text2VideoResponse: Decodable {
    let video_id: Int
    let detail: String
}

struct VideoStatusResponse: Decodable {
    let video_id: Int?
    let status: String
    let video_url: String?
    let error: String?

    init(id: Int?, status: String, video_url: String?, error: String?) {
        video_id = id
        self.status = status
        self.video_url = video_url
        self.error = error
    }
}
