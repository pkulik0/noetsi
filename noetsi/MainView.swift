//
//  MainView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI
import LocalAuthentication

struct MainView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @AppStorage("enableAuth") private var enableAuth = false
    
    @State private var showWelcomeView = false
    @State private var showNewNote = false
    @State private var showOptions = false
    @State private var isUnlocked = false

    var body: some View {
        VStack {
            if isUnlocked {
                mainViewBody
            } else {
                Button {
                    authenticate()
                } label: {
                    Label("Unlock notes", systemImage: "lock.fill")
                        .font(.headline)
                        .labelStyle(.titleAndIcon)
                }
                .padding()
                .background(Capsule().strokeBorder(Color.accentColor, lineWidth: 3))
                
                Button("Sign out", action: signOut)
                    .font(.headline)
                    .padding()
                    .opacity(0.8)
            }
        }
        .onAppear {
            authenticate()
        }
    }
    
    var mainViewBody: some View {
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
                    firestoreManager.fetchData()
                }
                
                addNoteButton
            }
            .navigationTitle("noetsi")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showOptions.toggle()
                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                    Button("Sign out") {
                        firestoreManager.signOut()
                        showWelcomeView = true
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .fullScreenCover(isPresented: $showWelcomeView) {
                WelcomeView()
            }
            .confirmationDialog("More", isPresented: $showOptions) {
                Button("\(enableAuth ? "Unlock" : "Lock") noetsi") {
                    enableAuth.toggle()
                }
                Button("Sign out", role: .destructive) {
                    signOut()
                }
            }
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
    
    func authenticate() {
        if enableAuth == false {
            isUnlocked = true
            return
        }

        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your notes") { authResult, authError in
                if authResult {
                    isUnlocked = true
                }
            }
        }
    }
    
    func signOut() {
        firestoreManager.signOut()
        enableAuth = false
        showWelcomeView = true
    }
}
