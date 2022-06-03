//
//  MainView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI
import Firebase

struct MainView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    
    @State private var changeView = false
    @State private var showNewNote = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    List(Array(firestoreManager.notes.enumerated()), id: \.offset) { noteIndex, note in
                        ZStack {
                            NavigationLink(destination: NoteView(noteID: noteIndex)) {}.opacity(0)
                            ListNoteRowView(note: note)
                                .shadow(radius: 5)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
                
                NavigationLink {
                    NoteView(noteID: 0)
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                        .background(Color.secondary)
                        .clipShape(Circle())
                }
                .simultaneousGesture(TapGesture().onEnded({
                    addNote()
                }))
                .buttonStyle(.plain)
                .offset(x: -20, y: 0)
            }
            .navigationTitle("noetsi")
            .toolbar {
                Button("Sign out") {
                    do {
                        try Auth.auth().signOut()
                        changeView = true
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $changeView) {
            WelcomeView()
        }
    }
    
    func addNote() {
        let note = Note(id: UUID().uuidString, title: "", body: "", tags: [], color: "blue")
        firestoreManager.notes.insert(note, at: 0)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
