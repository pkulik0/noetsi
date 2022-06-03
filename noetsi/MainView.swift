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
                    List {ç
                        ForEach(0..<firestoreManager.notes.count, id: \.self) { noteID in
                            ZStack {
                                NavigationLink(destination: NoteView(noteID: noteID)) {}.opacity(0)
                                ListNoteView(noteID: noteID)
                                    .shadow(radius: 5)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteNotes)
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign out") {
                        do {
                            try Auth.auth().signOut()
                            changeView = true
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
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
    
    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            firestoreManager.deleteNote(id: index)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
