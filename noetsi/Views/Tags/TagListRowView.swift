//
//  TagListRowView.swift
//  noetsi
//
//  Created by pkulik0 on 19/06/2022.
//

import SwiftUI

struct TagListRowView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

    let tag: String
    let noteCount: Int
    @Binding var selectedTag: String
    @State private var showDetails = false

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
