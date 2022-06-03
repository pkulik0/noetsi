//
//  NoteView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

struct NoteView: View {
    let noteID: Int
    
    @EnvironmentObject private var firestoreManager: FirestoreManager
    
    @State private var showMore: Bool = false
    @State private var showChangeColor: Bool = false
    @State private var showTagEditor: Bool = false
    
    @State private var noteColor: Color = .white
    
    var body: some View {
        ZStack {
            noteColor.opacity(0.4).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                TextField("Title", text: $firestoreManager.notes[noteID].title)
                    .font(.title.bold())
                
                ZStack(alignment: .topLeading) {
                    if firestoreManager.notes[noteID].body.isEmpty {
                        Text("...")
                            .opacity(0.75)
                            .padding(.top)
                    }
                    TextEditor(text: $firestoreManager.notes[noteID].body)
                        .onAppear {
                            UITextView.appearance().backgroundColor = .clear
                            setNoteColor()
                        }
                }
                
                TagListView(noteID: noteID)
            }
            .padding([.top, .leading])
        }
        .confirmationDialog("More", isPresented: $showMore) {
            Button("Change color") {
                showChangeColor = true
            }
            Button("Share a copy") {}
            Button("Delete", role: .destructive) {}
        }
        .confirmationDialog("Choose a color", isPresented: $showChangeColor, actions: {
            ForEach(Color.noteColors, id: \.self) { color in
                Button(color.description.capitalized) {
                    firestoreManager.notes[noteID].color = color.description
                    setNoteColor()
                }
            }
        })
        .sheet(isPresented: $showTagEditor, content: {
            TagEditorView(noteID: noteID)
        })
        .toolbar {
            Button {
                showMore = true
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        .onDisappear {
            firestoreManager.writeNote(id: noteID)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func setNoteColor() {
        noteColor = Color.noteColorByName[firestoreManager.notes[noteID].color] ?? .white
    }
}
