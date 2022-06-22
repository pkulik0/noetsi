//
//  NotesView.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

///
/// Displays all synced notes in an interactable and editable list.
///
///  ``NotesView`` is used as one of the main views of the app.
///  It allows the users to view, move (by dragging), delete and add notes.
///
///  The data is modified by interracing with ``FirestoreManager``.
///
struct NotesView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

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

                            NoteListRowView(note: $note)
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
                                .transition(.opacity)
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
            }
            .navigationTitle("noetsi")
            .toolbar {
                NavigationLink {
                    NoteView(note: $firestoreManager.notes.first ?? .constant(Note()))
                } label: {
                    Label("Add note", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
                .simultaneousGesture(TapGesture().onEnded({
                    firestoreManager.addNote()
                }))

            }
        }
        .navigationViewStyle(.stack)
    }
}
