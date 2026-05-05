//
//  AuthValidator.swift
//  PC
//
//  Created by somil jain on 05/05/26.
//

import Foundation

enum AuthValidator {
    static func validateInputs(username: String, email: String, password: String) -> String? {
        validateEmpty(username, email, password)
            ?? validateUsername(username)
            ?? validateEmail(email)
            ?? validatePassword(password)
    }

    static func validateEmpty(_ username: String, _ email: String, _ password: String) -> String? {
        if username.isEmpty || email.isEmpty || password.isEmpty { return "Please fill in all fields." }
        return nil
    }

    static func validateUsername(_ username: String) -> String? {
        if username.count > 20 { return "Username too long (max 20 characters)." }
        if !isValidUsername(username) {
            return "Username must be 3-20 characters long and contain only letters, numbers, and underscores."
        }
        return nil
    }

    static func validateEmail(_ email: String) -> String? {
        if email.count > 254 { return "Email too long." }
        if !isValidEmail(email) { return "Please enter a valid email address." }
        return nil
    }

    static func validatePassword(_ password: String) -> String? {
        if !isValidPassword(password) { return "Password must be at least 6 characters long." }
        return nil
    }

    static func isValidUsername(_ username: String) -> Bool {
        let regex = "^[a-zA-Z0-9_]{3,20}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
    }

    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }
}
