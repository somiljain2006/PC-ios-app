//
//  ChatPayloads.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Foundation

struct ProfileRow: Codable {
    let username: String
    let avatar_url: String?
}

struct CreateGroupPayload: Encodable {
    let name: String
    let created_by: UUID
}

struct AddMemberPayload: Encodable {
    let group_id: UUID
    let user_id: UUID
}

struct SendMessagePayload: Encodable {
    let group_id: UUID
    let sender_id: UUID
    let message: String
}

struct ChatGroupMemberWithGroup: Decodable {
    let chat_groups: ChatGroup
}

struct RenameGroupPayload: Encodable {
    let name: String
}
