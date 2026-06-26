//
//  VideoStatusResponse.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct Text2VideoStatusResponse: Decodable {
    let videoId: Int?
    let status: String
    let videoUrl: String?
    let error: String?
}
