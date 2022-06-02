//
//  TagEditorView.swift
//  noetsi
//
//  Created by qurrie on 02/06/2022.
//

import SwiftUI

struct TagEditorView: View {
    let noteID: Int
    
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) var dismiss
    
    @State private var newTag: String = ""

    var body: some View {
        List {
            Section {
                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
            }

            Section {
                ForEach(0..<firestoreManager.notes[noteID].tags.count) { index in
                    HStack {
                        TextField("Tag name", text: $firestoreManager.notes[noteID].tags[index])
                        Button(role: .destructive) {
                            // todo: remove tag
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                    }
                }
            } header: {
                Text("Current tags:")
            }
            
            Section {
                TextField("Tag", text: $newTag)
                Button {
                    // TODO: add tag
                    firestoreManager.notes[noteID].tags.append(newTag)
                } label: {
                    Label("Add", systemImage: "plus")
                }.disabled(!isTagValid(newTag))
            } header: {
                Text("Add a new tag?")
            }
        }
    }
    
    func isTagValid(_ tag: String) -> Bool {
        return !tag.isEmpty && tag.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
}
