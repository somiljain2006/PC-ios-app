//
//  SupabaseManager.swift
//  PC
//
//  Created by somil jain on 01/05/26.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        else {
            fatalError("Missing Supabase config in Info.plist")
        }

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
    }
}
