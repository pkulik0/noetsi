//
//  NoteView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

struct NoteView: View {
    let noteID: Int
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var showMore: Bool = false

    var body: some View {
        VStack {
            Divider()
            TextEditor(text: $firestoreManager.notes[noteID].body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red.opacity(0.5))
        }
        .confirmationDialog("More", isPresented: $showMore) {
            Button("Share") {}
            Button("Add tag") {}
            Button("Change color") {}
            Button("Delete", role: .destructive) {}
        }
        .toolbar {
            Button {
                showMore = true
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        .navigationTitle(firestoreManager.notes[noteID].title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TagView: View {
    let tag: String
    var body: some View {
        Text(tag)
            .font(.subheadline)
            .padding()
            .background(.red)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
