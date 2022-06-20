//
//  TagListView.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

struct TagListView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

    @State private var tags: [String] = []
    @State private var searchText = ""
    @State private var selectedTag = ""
    
    @State private var showSortingOptions = false
    
    enum SortingCriteria {
        case nameIncreasing, nameDecreasing, sizeIncreasing, sizeDecreasing
    }
    
    @State private var sortingCriteria: SortingCriteria = .sizeDecreasing
    
    private var counts: [String: Int] {
        var counts: [String: Int] = [:]
        tags.forEach({ counts[$0, default: 0] += 1 })
        return counts
    }
    
    @State private var filteredTags: [String] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTags, id: \.self) { tag in
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
            filteredTags = getFilteredTags()
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
    
    func fetchTags(notes: [Note]) {
        tags = []
        for note in notes {
            tags += note.tags
        }
        filteredTags = getFilteredTags()
    }
    
    func getFilteredTags() -> [String] {
        let filtertedTags = Array(Set(tags)).sorted(by: {
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
            return filtertedTags
        } else {
            return filtertedTags.filter({ $0.contains(searchText) })
        }
    }
}