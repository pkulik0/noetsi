//
//  NoteView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) private var dismiss
    
    @Binding var note: Note

    @State private var noteCopy = Note()

    @State private var showDeleteAlert: Bool = false
    @State private var showChangeColor: Bool = false
    @State private var showTagEditor: Bool = false
    @State private var showShareView: Bool = false
    
    @FocusState private var isBodyFocused: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                TextField("Title", text: $note.title)
                    .font(.title.bold())
                    .focused($isTitleFocused)
                                    
                ZStack(alignment: .topLeading) {
                    if note.body.isEmpty {
                        Text("Empty")
                            .opacity(0.5)
                            .padding(.top, 10)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $note.body)
                        .focused($isBodyFocused)
                        .onAppear {
                            UITextView.appearance().backgroundColor = .clear
                        }
                }
            }
            .padding([.top, .leading], 25)
            .background(NoteBackground(color: note.color, pattern: note.pattern))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
            
            TagListView(note: $note, showHeader: true)
                .padding(.vertical)
            
            if showChangeColor {
                ColorPicker(selection: $note.color, pattern: $note.pattern, isPresented: $showChangeColor)
                    .shadow(radius: 5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .alert("Are you sure?", isPresented: $showDeleteAlert, actions: {
            Button("Delete", role: .destructive, action: deleteNote)
            Button("Cancel", role: .cancel) {}
        })
        .sheet(isPresented: $showTagEditor, content: {
            TagEditorView(tags: $note.tags)
        })
        .toolbar {
            toolbarItems
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareView, content: {
            ShareItemsView(activityItems: [note.shareable], applicationActivites: nil)
        })
        .onAppear {
            noteCopy = note.copy()
        }
        .onDisappear {
            if note.isEmpty {
                note.deleteMe = true
            } else if note != noteCopy {
                firestoreManager.writeNote(note: note)
            }
        }
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    // add smth
                } label: {
                    Label("Add", systemImage: "plus")
                }
                Button {
                    withAnimation {
                        showChangeColor.toggle()
                    }
                } label: {
                    Label("Change color", systemImage: "paintpalette")
                }
                Button {
                    showShareView = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    isBodyFocused = false
                    isTitleFocused = false
                }
            }
        }
    }
    
    func deleteNote() {
        note.deleteMe = true
        dismiss()
    }
}
