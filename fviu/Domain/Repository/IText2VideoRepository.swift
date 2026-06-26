//
//  IVideoRepository.swift
//  fviu
//
//  Created by lilit on 24.06.26.
//

import Foundation

protocol IText2VideoRepository {
    func generate(prompt: String) async throws -> Int
    func status(id: Int) async throws -> Text2VideoStatusResponse
    func getTemplates() async throws -> [VideoTemplateResponse]
    func template2video( templateId: Int, imageData: Data, duration: Int?, quality: String?) async throws -> Int
}
