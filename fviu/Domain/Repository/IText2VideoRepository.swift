//
//  IVideoRepository.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

protocol IText2VideoRepository {
    func generate(prompt: String) async throws -> Int
    func status(id: Int) async throws -> Text2VideoStatusResponse
}
