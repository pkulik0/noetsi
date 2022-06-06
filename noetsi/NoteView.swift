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
    var noteIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showMore: Bool = false
    @State private var showChangeColor: Bool = false
    @State private var showTagEditor: Bool = false
    
    init(noteList: NoteList, noteIndex: Int) {
        self.noteList = noteList
        self.noteIndex = noteIndex
        self.note = noteList.notes.count > noteIndex ? noteList.notes[noteIndex] : Note()
    }

    var body: some View {
        ZStack {
            note.color.opacity(0.4).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                TextField("Title", text: $note.title)
                    .font(.title.bold())
                
                ZStack(alignment: .topLeading) {
                    if note.body.isEmpty {
                        Text("...")
                            .opacity(0.75)
                            .padding(.top)
                    }
                    TextEditor(text: $note.body)
                        .onAppear {
                            UITextView.appearance().backgroundColor = .clear
                        }
                }
                
                TagListView(note: note, showHeader: true)
                
                if showChangeColor {
                    ColorPicker(selection: $note.color, isPresented: $showChangeColor, items: Color.noteColors)
                }
            }
            .padding([.top, .leading])
        }
        .confirmationDialog("More", isPresented: $showMore) {
            Button("Change color") {
                withAnimation {
                    showChangeColor = true
                }
            }
            Button("Share a copy") {
                // TODO: share a copy
            }
            Button("Delete", role: .destructive, action: deleteNote)
        }
        .sheet(isPresented: $showTagEditor, content: {
            TagEditorView(note: note)
        })
        .toolbar {
            Button {
                showMore = true
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if note.title.isEmpty && note.body.isEmpty && note.tags.isEmpty {
                noteList.remove(at: noteIndex, firestoreManager: firestoreManager)
            } else {
                firestoreManager.writeNote(note: note)
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
