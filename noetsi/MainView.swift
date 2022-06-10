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
    @State private var showWelcomeView = false
    @State private var showNewNote = false
    
    var firstNote: Note {
        noteList.notes.first ?? Note()
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    if firestoreManager.status == .loading {
                        ProgressView()
                    }

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
                        .onMove(perform: move)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        withAnimation {
                            updateData()
                        }
                    }
                }
                
                addNoteButton
            }
            .navigationTitle("noetsi")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign out", action: signOut)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .fullScreenCover(isPresented: $showWelcomeView) {
            WelcomeView()
        }
        .onChange(of: firestoreManager.status, perform: handleFirestoreStatus)
    }
    
    var addNoteButton: some View {
        NavigationLink {
            NoteView(noteList: noteList, noteIndex: 0)
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .padding()
                .background(Color.secondary)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
        .simultaneousGesture(TapGesture().onEnded({
            addNote()
        }))
        .buttonStyle(.plain)
        .offset(x: -20, y: 0)
    }
    
    func handleFirestoreStatus(status: FirestoreStatus) {
        switch(status) {
        case .success:
            noteList.notes = firestoreManager.notes
        case .no_user:
            showWelcomeView = true
        case .failed:
            fallthrough
        case .loading:
            break
        }
    }
    
    func updateData() {
        firestoreManager.fetchNotes()
    }
    
    func addNote() {
        withAnimation {
            noteList.notes.insert(Note(), at: 0)
        }
    }
    
    func deleteNotes(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                noteList.remove(at: index, firestoreManager: firestoreManager)
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        noteList.notes.move(fromOffsets: source, toOffset: destination)
        // TODO: save order in db
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            showWelcomeView = true
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
