//
//  EditorialView.swift
//  PC
//
//  Created by somil jain on 23/04/26.
//

import Combine
import SwiftUI

struct EditorialView: View {
    @StateObject private var service = EditorialService()
    @FocusState private var isSearchFocused: Bool
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "All"
    @State private var selectedEditorialDetail: PCEditorialDetail?
    @State private var isDetailLoading = false
    @State private var detailErrorMessage: String?

    private let filters = ["All", "CodeChef", "Codeforces", "LeetCode"]

    private var filteredPCList: [PCEditorial] {
        service.pcEditorials.filter { editorial in
            let mappedPlatform = getMappedPlatform(editorial.platform)
            let platformMatch = selectedFilter == "All" || mappedPlatform == selectedFilter
            let searchMatch = searchText.isEmpty || editorial.contestName.localizedCaseInsensitiveContains(searchText)
            return platformMatch && searchMatch
        }
    }

    private func getMappedPlatform(_ code: String) -> String {
        switch code {
        case "LC": "LeetCode"
        case "CC": "CodeChef"
        case "CF": "Codeforces"
        default: code
        }
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    featuredSection
                    searchAndFiltersSection
                    editorialListSection
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                .padding(.bottom, 120)
                .onTapGesture {
                    isSearchFocused = false
                }
            }
            .refreshable {
                await service.fetchAllData()
            }
        }
        .task {
            if service.posts.isEmpty, service.pcEditorials.isEmpty {
                await service.fetchAllData()
            }
        }
        .sheet(item: $selectedEditorialDetail) { editorial in
            EditorialDetailView(editorial: editorial)
        }
        .alert("Error", isPresented: .constant(detailErrorMessage != nil)) {
            Button("OK") {
                detailErrorMessage = nil
            }
        } message: {
            Text(detailErrorMessage ?? "")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Latest ")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.white)
                + Text("Editorials")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(Color.primaryContainer)

            Text("Read every contest breakdown in one place")
                .font(.system(size: 14))
                .foregroundColor(Color.onSurfaceVariant)
                .frame(maxWidth: 280, alignment: .leading)
        }
    }

    private var featuredSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                if service.isLoadingCF {
                    ForEach(0 ..< 3, id: \.self) { _ in
                        FeaturedBlogSkeleton()
                            .frame(width: 330, height: 200)
                    }
                } else if service.posts.isEmpty {
                    Text("No featured editorials found.")
                        .foregroundColor(.onSurfaceVariant)
                        .frame(width: 320, height: 200)
                } else {
                    ForEach(service.posts) { post in
                        FeaturedBlogCard(post: post)
                            .frame(width: 330)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, -16)
        .animation(.smooth, value: service.posts)
    }

    private var searchAndFiltersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.outline.opacity(0.5))

                TextField("Search editorials...", text: $searchText)
                    .foregroundColor(.white)
                    .tint(Color.primaryContainer)
                    .focused($isSearchFocused)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.outline.opacity(0.6))
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSearchActive ? Color.surfaceContainerHigh : Color.surfaceContainerLowest)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSearchActive ? Color.primaryContainer : Color.outlineVariant.opacity(0.2),
                        lineWidth: isSearchActive ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isSearchActive)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            withAnimation { selectedFilter = filter }
                        } label: {
                            Text(filter)
                                .font(.system(size: 12, weight: .bold))
                                .textCase(.uppercase)
                                .modifier(LetterSpacing(value: 1.5))
                                .foregroundColor(selectedFilter == filter ? Color.onPrimaryContainer : Color.onSurfaceVariant)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(selectedFilter == filter ? Color.primaryContainer : Color.surfaceContainerHigh)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .stroke(Color.outlineVariant.opacity(0.10), lineWidth: selectedFilter == filter ? 0 : 1)
                                )
                                .cornerRadius(999)
                        }
                    }
                }
            }
        }
    }

    private var isSearchActive: Bool {
        isSearchFocused || !searchText.isEmpty
    }

    private var editorialListSection: some View {
        VStack(spacing: 16) {
            if service.isLoadingPC {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if filteredPCList.isEmpty {
                Text("No editorials found for this filter.")
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.top, 20)
            } else {
                ForEach(filteredPCList) { editorial in
                    PCEditorialCard(editorial: editorial) {
                        openEditorialDetail(editorial)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .animation(.smooth, value: filteredPCList)
    }

    private func openEditorialDetail(_ editorial: PCEditorial) {
        Task {
            isDetailLoading = true
            defer { isDetailLoading = false }

            do {
                selectedEditorialDetail = try await service.fetchEditorialDetail(slug: editorial.slug)
            } catch {
                detailErrorMessage = "Could not load editorial details."
            }
        }
    }
}

#Preview {
    EditorialView()
}
