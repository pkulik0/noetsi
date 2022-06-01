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
    
    @State private var color: Color = Color.white

    var body: some View {
        ZStack {
            color.opacity(0.25).ignoresSafeArea()
            
            TextEditor(text: $firestoreManager.notes[noteID].body)
                .padding([.top, .leading])
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear
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
            Button("Red") { color = .red }
            Button("Green") { color = .green }
            Button("Blue") { color = .blue }
            Button("Yellow") { color = .yellow }
            Button("Purple") { color = .purple }
            Button("White") { color = .white }
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
