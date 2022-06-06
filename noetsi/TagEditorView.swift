//
//  TagEditorView.swift
//  noetsi
//
//  Created by qurrie on 02/06/2022.
//

import SwiftUI

struct TagEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var note: Note
    @State private var newTag: String = ""

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(Array(note.tags.enumerated()), id: \.offset) { index, tag in
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
                        withAnimation {
                            note.tags.append(newTag)
                        }
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
    }
    
    func deleteTags(at offsets: IndexSet) {
        note.tags.remove(atOffsets: offsets)
    }

    func isTagValid(_ tag: String) -> Bool {
        return !tag.isEmpty && tag.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
}
