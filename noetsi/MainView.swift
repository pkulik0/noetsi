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
    @State private var showAuthError = false

    var body: some View {
        Group {
            if isUnlocked {
                mainViewBody
            } else {
                authBody
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
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        print("pin")
                                    } label: {
                                        Label("Pin", systemImage: "pin.fill")
                                    }
                                    .tint(.blue)
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
            .alert("Cannot enable authentication", isPresented: $showAuthError, actions: {
                Button("OK") {}
            }, message: {
                Text("Your device  does not support local authentication.")
            })
            .confirmationDialog("More", isPresented: $showOptions) {
                Button("\(enableAuth ? "Unlock" : "Lock") noetsi") {
                    if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
                        enableAuth.toggle()
                    } else {
                        enableAuth = false
                        showAuthError = true
                    }
                }
                Button("Sign out", role: .destructive) {
                    signOut()
                }
            }
        }
    }
    
    var authBody: some View {
        VStack {
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
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your notes") { authResult, _ in
                if authResult {
                    withAnimation {
                        isUnlocked = true
                    }
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
