//
//  TagEditorView.swift
//  noetsi
//
//  Created by pkulik0 on 02/06/2022.
//

import SwiftUI

struct TagEditorView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) var dismiss
    
    @Binding var tags: [String]
    @State private var newTag: String = ""
    @State private var uniqueTags: [String] = []
    
    @State private var showSuggestions = false
    private var suggestedTags: [String] {
        uniqueTags.filter({ $0.lowercased().contains(newTag.lowercased()) })
    }

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
    
    func deleteTags(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
        updateSuggestions()
    }

    func isTagValid(_ tag: String) -> Bool {
        return !tag.isEmpty && tag.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && !tags.contains(tag)
    }
}
