//
//  ChatCache.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Foundation

class ChatCache {
    static let shared = ChatCache()

    var messages: [UUID: [ChatMessage]] = [:]

    private init() {}

    func getMessages(for groupId: UUID) -> [ChatMessage]? {
        messages[groupId]
    }

    func saveMessages(_ newMessages: [ChatMessage], for groupId: UUID) {
        messages[groupId] = newMessages
    }

    func clearCache(for groupId: UUID) {
        messages.removeValue(forKey: groupId)
    }

    func clearAll() {
        messages.removeAll()
    }
}
