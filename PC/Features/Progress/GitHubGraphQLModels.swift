//
//  GitHubGraphQLModels.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import Foundation

struct GitHubGraphQLRequest: Encodable {
    let query: String
    let variables: Variables

    struct Variables: Encodable {
        let login: String
    }
}

struct GitHubGraphQLResponse: Decodable {
    let data: GitHubUserData
}

struct GitHubUserData: Decodable {
    let user: GitHubUser
}

struct GitHubUser: Decodable {
    let contributionsCollection: ContributionsCollection
}

struct ContributionsCollection: Decodable {
    let contributionCalendar: ContributionCalendar
}

struct ContributionCalendar: Decodable {
    let totalContributions: Int
    let weeks: [ContributionWeek]
}

struct ContributionWeek: Decodable {
    let contributionDays: [ContributionDay]
}

struct ContributionDay: Decodable {
    let contributionCount: Int
    let date: String
}
