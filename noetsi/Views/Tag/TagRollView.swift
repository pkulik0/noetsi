//
//  TagRollView.swift
//  noetsi
//
//  Created by pkulik0 on 03/06/2022.
//

import SwiftUI

/// Displays a ``Note``'s tags in a scrollable horizontal view.
struct TagRollView: View {
    
    /// The ``Note`` that is the source of the data.
    @Binding var note: Note

    /// Setting this to true disables the header.
    var compact: Bool = false
    
    /// Controls the visiblity of ``TagEditorView``.
    @State private var showTagEditor = false
    
    @EnvironmentObject private var firestoreManager: FirestoreManager

    var body: some View {
        VStack(alignment: .leading) {
            if !compact {
                Text("Tags:")
                    .font(.headline)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(note.tags, id: \.self) { tag in
                        TagView(tag: tag, color: note.color)
                            .font(.caption)
                    }
                    Button {
                        showTagEditor = true
                    } label: {
                        Label("Edit tags", systemImage: note.tags.count > 0 ? "pencil" : "plus")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Circle().fill(note.color).opacity(0.75))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("editTagsButton")
                }
            }
        }
        .sheet(isPresented: $showTagEditor) {
            TagEditorView(tags: $note.tags)
                .onDisappear {
                    firestoreManager.writeNote(note: note)
                }
        }
    }
}
