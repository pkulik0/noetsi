//
//  TagsView.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

/// ``TagsView`` is one of the application's main views. It is used to display all ``Note``s with a given tag.
struct TagsView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

    /// The available tags.
    @State private var tags: [String] = []
    
    /// Currently searched text.
    @State private var searchText = ""
    
    /// Currently selected tag. Only one tag at a time can be expanded.
    @State private var selectedTag = ""
    
    /// Show a confirmation dialog with sorting options.
    @State private var showSortingOptions = false
    
    /// Available sorting criteria.
    enum SortingCriteria {
        case nameIncreasing, nameDecreasing, sizeIncreasing, sizeDecreasing
    }
    
    /// Selected sorting option
    @State private var sortingCriteria: SortingCriteria = .sizeDecreasing
    
    /// Tags sorted by the selected ``SortingCriteria``.
    @State private var sortedTags: [String] = []
    
    /// Counts of ``Note``s with a given tag.
    private var counts: [String: Int] {
        var counts: [String: Int] = [:]
        tags.forEach({ counts[$0, default: 0] += 1 })
        return counts
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedTags, id: \.self) { tag in
                    TagListRowView(tag: tag, noteCount: counts[tag, default: 0], selectedTag: $selectedTag)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Tags")
            .toolbar {
                Button {
                    showSortingOptions.toggle()
                } label: {
                    Label("Sort By", systemImage: "arrow.up.arrow.down")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .onAppear {
            fetchTags(notes: firestoreManager.notes)
        }
        .onChange(of: firestoreManager.notes) { notes in
            fetchTags(notes: notes)
        }
        .onChange(of: sortingCriteria, perform: { _ in
            sortedTags = getSortedTags()
        })
        .confirmationDialog("Sort By", isPresented: $showSortingOptions) {
            Button("Name - A to Z") {
                sortingCriteria = .nameIncreasing
            }
            Button("Name - Z to A") {
                sortingCriteria = .nameDecreasing
            }
            Button("Size - Small to Large") {
                sortingCriteria = .sizeIncreasing
            }
            Button("Size - Large to Small") {
                sortingCriteria = .sizeDecreasing
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    /// Fetch a list of all existing tags.
    func fetchTags(notes: [Note]) {
        tags = []
        for note in notes {
            tags += note.tags
        }
        sortedTags = getSortedTags()
    }
    
    /// Sort tags by the selected ``SortingCriteria``.
    func getSortedTags() -> [String] {
        let sortedTags = Array(Set(tags)).sorted(by: {
            switch sortingCriteria {
            case .nameIncreasing:
                return $0 < $1
            case .nameDecreasing:
                return $0 > $1
            case .sizeIncreasing:
                return counts[$0, default: 0] < counts[$1, default: 0]
            case .sizeDecreasing:
                return counts[$0, default: 0] > counts[$1, default: 0]
            }
        })
        if searchText.isEmpty {
            return sortedTags
        } else {
            return sortedTags.filter({ $0.contains(searchText) })
        }
    }
}
