//
//  NoteView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

struct NoteView: View {
    let noteID: Int
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var showMore: Bool = false
    @State private var showChangeColor: Bool = false
    
    @State private var noteColor: Color = Color.white

    var body: some View {
        ZStack {
            noteColor.opacity(0.25).ignoresSafeArea()
            
            TextEditor(text: $firestoreManager.notes[noteID].body)
                .padding([.top, .leading])
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear
                    setNoteColor()
                }
        }
        .confirmationDialog("More", isPresented: $showMore) {
            Button("Change color") {
                showMore = false
                showChangeColor = true
            }
            Button("Share a copy") {}
            Button("Delete", role: .destructive) {}
        }
        .confirmationDialog("Choose a color", isPresented: $showChangeColor, actions: {
            Button("Red") {
                firestoreManager.notes[noteID].color = "red"
                setNoteColor()
            }
            Button("Green") {
                firestoreManager.notes[noteID].color = "green"
                setNoteColor()
            }
            Button("Blue") {
                firestoreManager.notes[noteID].color = "blue"
                setNoteColor()
            }
            Button("Yellow") {
                firestoreManager.notes[noteID].color = "yellow"
                setNoteColor()
            }
            Button("Purple") {
                firestoreManager.notes[noteID].color = "purple"
                setNoteColor()
            }
            Button("White") {
                firestoreManager.notes[noteID].color = "white"
                setNoteColor()
            }
        })
        .toolbar {
            Button {
                showMore = true
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        .navigationTitle(firestoreManager.notes[noteID].title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func setNoteColor() {
        switch firestoreManager.notes[noteID].color {
        case "red":
            noteColor = .red
            break
        case "green":
            noteColor = .green
            break
        case "blue":
            noteColor = .blue
            break
        case "yellow":
            noteColor = .yellow
            break
        case "purple":
            noteColor = .purple
            break
        default:
            noteColor = .white
            break
        }
    }
}

struct TagView: View {
    let tag: String
    var body: some View {
        Text(tag)
            .font(.subheadline)
            .padding()
            .background(.red)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
