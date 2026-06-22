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
