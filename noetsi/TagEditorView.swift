//
//  TagEditorView.swift
//  noetsi
//
//  Created by qurrie on 02/06/2022.
//

import SwiftUI

struct TagEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var tags: [String]
    @State private var newTag: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        HStack {
                            Image(systemName: "\(index).circle")
                            Text(tag)
                        }
                    }
                    .onDelete(perform: deleteTags)
                    .animation(.default, value: tags)
                } header: {
                    Text("Current tags:")
                }
                
                Section {
                    TextField("Tag", text: $newTag)
                    
                    Button {
                        tags.append(newTag)
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
        tags.remove(atOffsets: offsets)
    }

    func isTagValid(_ tag: String) -> Bool {
        return !tag.isEmpty && tag.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
}
