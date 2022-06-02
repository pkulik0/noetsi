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
    
    @State private var noteColor: Color = .white
    
    let supportedColors: [Color] = [.red, .green, .blue, .yellow, .purple, .white]

    var colorByName: [String: Color] {
        var result: [String: Color] = [:]
        for color in supportedColors {
            result[color.description] = color
        }
        return result
    }

    var body: some View {
        ZStack {
            noteColor.opacity(0.25).ignoresSafeArea()
            
            VStack {
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
                
                HStack {
                    ForEach(0..<firestoreManager.notes[noteID].tags.count) { tagID in
                        TagView(noteID: noteID, tagID: tagID)
                    }
                }
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
            ForEach(supportedColors, id: \.self) { color in
                Button(color.description.capitalized) {
                    firestoreManager.notes[noteID].color = color.description
                    setNoteColor()
                }
            }
        })
        .toolbar {
            Button {
                showMore = true
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func setNoteColor() {
        noteColor = colorByName[firestoreManager.notes[noteID].color] ?? .white
    }
}
