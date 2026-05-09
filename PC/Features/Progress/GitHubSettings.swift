//
//  GitHubSettings.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class GitHubSettings: ObservableObject {
    @AppStorage("github_username")
    var username: String = ""

    @AppStorage("github_token")
    var token: String = ""

    var isConfigured: Bool {
        !username.isEmpty && !token.isEmpty
    }
}
