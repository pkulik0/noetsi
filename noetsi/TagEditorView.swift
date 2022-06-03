//
//  TagEditorView.swift
//  noetsi
//
//  Created by qurrie on 02/06/2022.
//

import SwiftUI

struct TagEditorView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) var dismiss
    
    @State private var newTag: String = ""
    
    let noteID: Int

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(Array(firestoreManager.notes[noteID].tags.enumerated()), id: \.offset) { index, tag in
                        HStack {
                            Image(systemName: "\(index).circle")
                            Text(tag)
                        }
                    }
                    .onDelete(perform: deleteTags)
                } header: {
                    Text("Current tags:")
                }
                
                Section {
                    TextField("Tag", text: $newTag)
                    Button {
                        firestoreManager.notes[noteID].tags.append(newTag)
                        newTag = ""
                    } label: {
                        Label("Add", systemImage: "plus")
                    }.disabled(!isTagValid(newTag))
                } header: {
                    Text("Add a new tag")
                }
            }
            .navigationTitle("\(firestoreManager.notes[noteID].title)'s tags")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            firestoreManager.writeNote(id: noteID)
        }
    }
    
    func deleteTags(at offsets: IndexSet) {
        firestoreManager.notes[noteID].tags.remove(atOffsets: offsets)
    }

    func isTagValid(_ tag: String) -> Bool {
        return !tag.isEmpty && tag.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
}
