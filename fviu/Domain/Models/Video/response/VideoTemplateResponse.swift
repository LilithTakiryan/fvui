//
//  PixverseTemplate.swift
//  fviu
//
//  Created by lilit on 25.06.26.
//
import Foundation
struct VideoTemplatesContainerResponse: Decodable {
    let id: Int
    let applicationId: String
    let applicationNumber: Int
    let subscriptionEnabled: Bool
    let templates: [VideoTemplateResponse]
}

struct VideoTemplateResponse: Decodable {
    let id: Int
    let templateId: Int64
    let prompt: String
    let name: String
    let category: String
    let templateModel: String? 
    let duration: Int
    let isCustom: Bool
    let previewSmall: String
    let previewLarge: String
    let isActive: Bool
}
