//
//  DolaChatItem.swift
//  fviu
//
//  Created by lilit on 22.06.26.
//

struct DolaChatItem: Identifiable, Decodable {
    let id: String
    let title: String?
    let persona_id: Int?
    let updated_at: String
    let last_message_preview: String?

    enum CodingKeys: String, CodingKey {
        case id = "chat_id"
        case title, persona_id, updated_at, last_message_preview
    }
}
