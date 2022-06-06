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
    
    @StateObject private var noteList: NoteList = NoteList()
    
    var firstNote: Note {
        noteList.notes.first ?? Note()
    }
    
    @State private var changeView = false
    @State private var showNewNote = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    List {
                        ForEach(Array(noteList.notes.enumerated()), id: \.offset) { noteIndex, note in
                            ZStack {
                                NavigationLink {
                                    NoteView(noteList: noteList, noteIndex: noteIndex)
                                } label: {}
                                    .opacity(0)
                                ListNoteView(note: note)
                                    .shadow(radius: 5)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.plain)
                }
                
                NavigationLink {
                    NoteView(noteList: noteList, noteIndex: 0)
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
        .onAppear {
            noteList.notes = firestoreManager.notes
        }
        .onChange(of: firestoreManager.status) { _ in
            noteList.notes = firestoreManager.notes
        }
    }
    
    func addNote() {
        withAnimation {
            noteList.notes.insert(Note(), at: 0)
        }
    }
    
    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            noteList.remove(at: index, firestoreManager: firestoreManager)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
