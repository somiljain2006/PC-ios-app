//
//  PlatformSetupView.swift
//  PC
//
//  Created by somil jain on 08/05/26.
//

import SwiftUI

struct PlatformSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ProgressViewModel

    @State private var githubUsername: String = ""
    @State private var githubToken: String = ""
    @State private var leetcode: String = ""
    @State private var codeforces: String = ""
    @State private var codechef: String = ""
    @State private var atcoder: String = ""

    var body: some View {
        NavigationView {
            List {
                githubSection
                competitiveSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Connect Platforms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: save)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .onAppear(perform: loadCurrent)
        }
    }

    private var githubSection: some View {
        Section {
            PlatformField(
                label: "Username",
                placeholder: "torvalds",
                text: $githubUsername
            )
            PlatformField(
                label: "Token",
                placeholder: "ghp_xxxxxxxxx",
                text: $githubToken,
                isSecure: true
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Required permissions")
                    .font(.caption).foregroundColor(.secondary)
                Text("read:user, public_repo")
                    .font(.caption2).foregroundColor(.secondary)
            }
            .padding(.vertical, 2)

        } header: {
            PlatformSectionHeader(image: "github", title: "GitHub")
        }
    }

    private var competitiveSection: some View {
        Section {
            PlatformField(
                label: "LeetCode",
                placeholder: "your_username",
                text: $leetcode
            )
            PlatformField(
                label: "Codeforces",
                placeholder: "tourist",
                text: $codeforces
            )
            PlatformField(
                label: "CodeChef",
                placeholder: "gennady",
                text: $codechef
            )
            PlatformField(
                label: "AtCoder",
                placeholder: "tourist",
                text: $atcoder
            )
        } header: {
            Label("Competitive Platforms", systemImage: "trophy")
                .font(.footnote.weight(.semibold))
        }
    }

    private func loadCurrent() {
        githubUsername = UserDefaults.standard.string(forKey: "github_username") ?? ""
        githubToken = UserDefaults.standard.string(forKey: "github_token") ?? ""
        leetcode = vm.handles.leetcode ?? ""
        codeforces = vm.handles.codeforces ?? ""
        codechef = vm.handles.codechef ?? ""
        atcoder = vm.handles.atcoder ?? ""
    }

    private func save() {
        UserDefaults.standard.set(githubUsername, forKey: "github_username")
        UserDefaults.standard.set(githubToken, forKey: "github_token")

        vm.setLeetCodeUsername(leetcode, refreshAfter: false)
        vm.setCodeforcesHandle(codeforces, refreshAfter: false)
        vm.setCodeChefHandle(codechef, refreshAfter: false)
        vm.setAtCoderHandle(atcoder, refreshAfter: false)

        Task { await vm.refresh() }
        dismiss()
    }
}

private struct PlatformField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundColor(.primary)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundColor(.primary)
            }
        }
    }
}

private struct PlatformSectionHeader: View {
    let image: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            Text(title)
        }
        .font(.footnote.weight(.semibold))
    }
}
