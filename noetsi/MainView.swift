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
    @Environment(\.dismiss) private var dismiss
    @AppStorage("enableAuth") private var enableAuth = false
    
    @State private var showNewNote = false
    @State private var showOptions = false
    @State private var showAuthError = false

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
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button {
                                        firestoreManager.deleteNote(id: note.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                    .tint(.red)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        guard let index = firestoreManager.notes.firstIndex(of: note) else {
                                            return
                                        }
                                        firestoreManager.move(from: IndexSet(integer: Int(index)), to: 0)
                                    } label: {
                                        Label("Top", systemImage: "arrow.up")
                                    }
                                    .tint(.blue)
                                }
                                .onDrag {
                                    UISelectionFeedbackGenerator().selectionChanged()
                                    return NSItemProvider(item: nil, typeIdentifier: nil)
                                }
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
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
            .toolbar {
                Button {
                    showOptions.toggle()
                } label: {
                    Label("More", systemImage: "ellipsis")
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
    
    func signOut() {
        firestoreManager.signOut()
        enableAuth = false
        dismiss()
    }
}
