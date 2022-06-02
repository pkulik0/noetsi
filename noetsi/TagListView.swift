//
//  TagListView.swift
//  noetsi
//
//  Created by qurrie on 03/06/2022.
//

import SwiftUI

struct TagListView: View {
    let noteID: Int

    @EnvironmentObject private var firestoreManager: FirestoreManager
    
    @State private var showTagEditor = false

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(firestoreManager.notes[noteID].tags, id: \.self) { tag in
                    TagView(tag: tag)
                        .font(.caption)
                }
                Button {
                    showTagEditor = true
                } label: {
                    Image(systemName: firestoreManager.notes[noteID].tags.count > 0 ? "pencil" : "plus")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Circle().fill(.secondary))
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showTagEditor) {
            TagEditorView(noteID: noteID)
        }
    }
}
