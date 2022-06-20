//
//  TagListView.swift
//  noetsi
//
//  Created by pkulik0 on 03/06/2022.
//

import SwiftUI

struct TagsView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

    @State private var showTagEditor = false
    
    @Binding var note: Note
    var updateNote: Bool = false
    let compact: Bool

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
