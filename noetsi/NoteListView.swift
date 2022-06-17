//
//  NoteListView.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

struct NoteListView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager

    var body: some View {
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
            
            CircleButton(imageName: "plus") {
                NoteView(note: $firestoreManager.notes.first ?? .constant(Note()))
            } onClick: {
                firestoreManager.addNote()
            }

        }
    }
}
