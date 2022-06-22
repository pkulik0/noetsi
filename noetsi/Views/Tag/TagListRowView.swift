//
//  TagListRowView.swift
//  noetsi
//
//  Created by pkulik0 on 19/06/2022.
//

import SwiftUI

/// ``TagListRowView`` displays a list row contaning all ``Note``s with a given tag.
struct TagListRowView: View {

    /// The tag displayed in this row.
    let tag: String
    
    /// The amount of notes with ``tag``.
    let noteCount: Int
    
    /// The list's element that is currently expanded.
    @Binding var selectedTag: String
    
    /// Controls the visiblity of ``Note``s  with the selected tag.
    @State private var showDetails = false
    
    @EnvironmentObject private var firestoreManager: FirestoreManager

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Image(systemName: showDetails ? "chevron.down" : "chevron.right")
                    .padding(.trailing, 10)
                    .foregroundColor(.secondary)
                    .font(.title3)
                Text("#")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Text(tag)
                    .font(.headline)
                    .padding(.trailing, 5)
                Text("(\(noteCount) \(noteCount == 1 ? "note" : "notes"))")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            .onTapGesture {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation {
                    selectedTag = selectedTag == tag ? "" : tag
                }
            }

            if showDetails {
                ForEach($firestoreManager.notes.filter({ $0.tags.wrappedValue.contains(tag) })) { $note in
                    ZStack {
                        NavigationLink {
                            NoteView(note: $note)
                        } label: {}.opacity(0)

                        NoteListRowView(note: $note)
                    }
                    .transition(.slide.combined(with: .opacity))
                }
            }
        }
        .onChange(of: selectedTag) { newSelectedTag in
            withAnimation {
                showDetails = (newSelectedTag == tag)
            }
        }
    }
}
