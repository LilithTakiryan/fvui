//
//  VideoStatusResponse.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct VideoStatusResponse: Decodable {
    let video_id: Int?
    let status: String
    let video_url: String?
    let error: String?
}
