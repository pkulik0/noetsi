//
//  NoteView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

    @ObservedObject var noteList: NoteList
    @ObservedObject var note: Note
    private let noteUnmodified: Note
    var noteIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showMore: Bool = false
    @State private var showChangeColor: Bool = false
    @State private var showTagEditor: Bool = false
    
    @FocusState private var isBodyFocused: Bool
    @FocusState private var isTitleFocused: Bool
    
    init(noteList: NoteList, noteIndex: Int) {
        self.noteList = noteList
        self.noteIndex = noteIndex
        self.note = noteList.notes.count > noteIndex ? noteList.notes[noteIndex] : Note()
        // TODO: Fix this bugged implementation of noteUnmodified, needs to overwrite the note in firestoreManager (or abandon not saving)
        self.noteUnmodified = noteList.notes.count > noteIndex ? noteList.notes[noteIndex].copy() : Note()
    }

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
                
                TagListView(note: note, showHeader: true)
                
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
            TagEditorView(note: note, updateNote: false)
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
        .onDisappear {
            if note.title.isEmpty && note.body.isEmpty && note.tags.isEmpty {
                noteList.remove(at: noteIndex, firestoreManager: firestoreManager)
            } else if note != noteUnmodified {
                firestoreManager.writeNote(note: note)
                print("bbbbb")
            } else {
                print("aaaaa")
            }
        }
    }
    
    func deleteNote() {
        note.title = ""
        note.body = ""
        note.tags = []

        dismiss()
    }
}
