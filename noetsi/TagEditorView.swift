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
    
    @ObservedObject var note: Note
    @State private var newTag: String = ""
    let updateNote: Bool

    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(Array(note.tags.enumerated()), id: \.offset) { index, tag in
                        HStack {
                            Image(systemName: "\(index).circle")
                            Text(tag)
                        }
                    }
                    .onDelete(perform: deleteTags)
                    .animation(.default, value: note.tags)
                } header: {
                    Text("Current tags:")
                }
                
                Section {
                    TextField("Tag", text: $newTag)
                    
                    Button {
                        note.tags.append(newTag)
                        newTag = ""
                    } label: {
                        Label("Add", systemImage: "plus")
                    }.disabled(!isTagValid(newTag))
                } header: {
                    Text("Add a new tag")
                }
            }
            .navigationTitle("Tag Editor")
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
            if updateNote {
                firestoreManager.writeNote(note: note)
            }
        }
    }
    
    func deleteTags(at offsets: IndexSet) {
        note.tags.remove(atOffsets: offsets)
    }

    func isTagValid(_ tag: String) -> Bool {
        return !tag.isEmpty && tag.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
}
