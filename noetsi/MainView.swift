//
//  MainView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    
    @State private var showWelcomeView = false
    @State private var showNewNote = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach($firestoreManager.notes) { $note in
                        ZStack {
                            NavigationLink {
                                NoteView(note: $note)
                            } label: {}
                                .opacity(0)
                            ListNoteView(note: $note)
                                .shadow(radius: 5)
                                .onChange(of: note.deleteMe) { _ in
                                    firestoreManager.deleteNote(id: note.id)
                                }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: firestoreManager.deleteNotes)
                    .onMove(perform: firestoreManager.move)
                }
                .listStyle(.plain)
                .animation(.default, value: firestoreManager.notes)
                .refreshable {
                    firestoreManager.updateData()
                }
                
                addNoteButton
            }
            .navigationTitle("noetsi")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign out") {
                        firestoreManager.signOut()
                        showWelcomeView = true
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .fullScreenCover(isPresented: $showWelcomeView) {
            WelcomeView()
        }
    }
    
    var addNoteButton: some View {
        NavigationLink {
            NoteView(note: $firestoreManager.notes.first ?? .constant(Note()))
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .padding()
                .background(Color.secondary)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
        .simultaneousGesture(TapGesture().onEnded({
            firestoreManager.addNote()
        }))
        .buttonStyle(.plain)
        .offset(x: -20, y: 0)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
