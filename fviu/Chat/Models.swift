//
//  Models.swift
//  fviu
//
//  Created by lilit on 20.06.26.
//


struct DolaChatItem: Identifiable, Decodable, Sendable {
    let id: String
    let title: String?
    let persona_id: Int?
    let updated_at: String
    let last_message_preview: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "chat_id"
        case title
        case persona_id
        case updated_at
        case last_message_preview
    }
}

struct DolaMessageItem: Decodable, Sendable {
    let role: String
    let content: String
    let created_at: String
}
