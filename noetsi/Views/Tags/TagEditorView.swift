//
//  TagEditorView.swift
//  noetsi
//
//  Created by pkulik0 on 02/06/2022.
//

import SwiftUI

/// ``TagEditorView`` displays a ``Note``'s tags and allows users to edit them and add new ones.
struct TagEditorView: View {
    
    /// The object containing a ``Note``'s tags
    @Binding var tags: [String]
    
    /// The value currently sitting in the text field used for new tags.
    @State private var newTag: String = ""
    
    /// Holds a list of unique tags that are not a part of this ``Note``'s tags.
    @State private var uniqueTags: [String] = []
    
    /// Controls the visiblity of the suggestion bar.
    @State private var showSuggestions = false
    
    /// Holds a list of all uniqueTags that contain the text put into newTag.
    private var suggestedTags: [String] {
        uniqueTags.filter({ $0.lowercased().contains(newTag.lowercased()) })
    }
    
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        Text("#")
                            .foregroundColor(.secondary)
                        +
                        Text(tag)
                            .bold()
                    }
                    .onDelete(perform: deleteTags)
                    .animation(.default, value: tags)
                } header: {
                    Text("Current tags:")
                }
                
                if showSuggestions {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(suggestedTags, id: \.self) { tag in
                                    Button {
                                        withAnimation {
                                            tags.append(tag)
                                            newTag = ""
                                        }
                                    } label: {
                                        Text("#")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                        +
                                        Text(tag)
                                            .font(.headline)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.trailing)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    } header: {
                        Text("Tap suggestion to add")
                    }
                }
                
                Section {
                    TextField("Tag", text: $newTag)
                    
                    Button {
                        withAnimation {
                            tags.append(newTag)
                            newTag = ""
                        }
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
            .onAppear {
                updateSuggestions()
            }
            .onChange(of: tags, perform: { _ in
                updateSuggestions()
            })
            .onChange(of: suggestedTags) { tags in
                withAnimation {
                    showSuggestions = !tags.isEmpty
                }
            }
        }
    }
    
    /// Updates the tag suggestions based on the currently stored ``Note``s
    func updateSuggestions() {
        firestoreManager.notes.forEach { note in
            uniqueTags += note.tags
        }
        uniqueTags = Array(Set(uniqueTags))
        
        // Do not suggest duplicates
        tags.forEach { tag in
            guard let index = uniqueTags.firstIndex(of: tag) else {
                return
            }
            uniqueTags.remove(at: index)
        }
    }
    
    /// Delete a tag from the collection and update suggestions.
    func deleteTags(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
        updateSuggestions()
    }

    /// Check if a tag is valid.
    func isTagValid(_ tag: String) -> Bool {
        return !tag.isEmpty && tag.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && !tags.contains(tag)
    }
}
