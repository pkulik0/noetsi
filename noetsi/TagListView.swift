//
//  TagListView.swift
//  noetsi
//
//  Created by pkulik0 on 03/06/2022.
//

import SwiftUI

struct TagListView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

    @State private var showTagEditor = false
    
    @Binding var note: Note
    var updateNote: Bool = false
    let showHeader: Bool

    var body: some View {
        VStack(alignment: .leading) {
            if showHeader {
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
                        Image(systemName: note.tags.count > 0 ? "pencil" : "plus")
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
