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

    @State private var showMore: Bool = false
    @State private var showChangeColor: Bool = false
    @State private var showTagEditor: Bool = false
    
    @FocusState private var isBodyFocused: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        ZStack {
            note.color.opacity(0.4).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                TextField("Title", text: $note.title)
                    .font(.title.bold())
                    .focused($isTitleFocused)
                
                ZStack(alignment: .topLeading) {
                    if note.body.isEmpty {
                        Text("...")
                            .opacity(0.5)
                            .padding(.top)
                    }
                    TextEditor(text: $note.body)
                        .focused($isBodyFocused)
                        .onAppear {
                            UITextView.appearance().backgroundColor = .clear
                        }
                }
                
                TagListView(note: $note, showHeader: true)
                
                if showChangeColor {
                    ColorPicker(selection: $note.color, isPresented: $showChangeColor, items: Color.noteColors)
                        .transition(.move(edge: .bottom))
                }
            }
            .padding()
        }
        .confirmationDialog("More", isPresented: $showMore) {
            Button("Change color") {
                withAnimation {
                    showChangeColor.toggle()
                }
            }
            Button("Share a copy") {
                // TODO: share a copy
            }
            Button("Delete", role: .destructive, action: deleteNote)
        }
        .sheet(isPresented: $showTagEditor, content: {
            TagEditorView(tags: $note.tags)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showMore = true
                } label: {
                    Label("More", systemImage: "ellipsis")
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
        .navigationBarTitleDisplayMode(.inline)
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
    
    func deleteNote() {
        note.deleteMe = true
        dismiss()
    }
}
