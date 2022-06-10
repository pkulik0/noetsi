//
//  FirestoreManager.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import Firebase
import SwiftUI

enum FirestoreStatus {
    case loading, success, failed, no_user
}

class FirestoreManager: ObservableObject {
    @Published var notes: [Note] = []
    @Published var status: FirestoreStatus = .loading
    
    let db = Firestore.firestore()
    
    init() {
        fetchNotes()
    }

    var uid: String? {
        if let user = Auth.auth().currentUser {
            return String(user.uid)
        }
        return nil
    }

    func writeNote(note: Note) {
        guard let uid = uid else {
            return
        }

        db.collection(uid).document(note.id).setData(["title": note.title, "body": note.body, "tags": note.tags, "timestamp": note.timestamp, "color": note.color.description], merge: true) { error in
            if let error = error {
                print("Could not write/update note \(note.id): \(error.localizedDescription)")
            } else {
                if let index = self.notes.firstIndex(where: { $0 == note }) {
                    self.notes[index] = note
                    print("Note updated: \(note.id)")
                } else {
                    self.notes.insert(note, at: 0)
                    print("Note created: \(note.id)")
                }
            }
        }
    }

    func deleteNote(id: String) {
        guard let uid = uid else {
            return
        }

        db.collection(uid).document(id).delete() { error in
            if let error = error {
                print("Could not delete note \(id): \(error.localizedDescription)")
            } else {
                print("Note deleted: \(id)")
                guard let index = self.notes.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.notes.remove(at: index)
            }
        }
    }
    
    func fetchNotes() {
        guard let uid = uid else {
            status = .no_user
            return
        }
        self.status = .loading

        db.collection(uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.status = .failed
                print(error.localizedDescription)
                return
            }
            
            var notes_buffer: [Note] = []

            for document in querySnapshot!.documents {
                let note: Note = Note(id: document.documentID)

                note.title = document.data()["title"] as? String ?? "Unknown title"
                note.body = document.data()["body"] as? String ?? "Unknown content"
                note.tags = document.data()["tags"] as? [String] ?? []
                note.timestamp = document.data()["timestamp"] as? Int ?? 0
                
                let colorName = document.data()["color"] as? String ?? Color.noteColors[0].description
                note.color = Color.noteColorByName[colorName] ?? Color.noteColors[0]
                
                notes_buffer.append(note)
            }
            self.notes = notes_buffer
            self.status = .success
        }
    }
    
    func updateData() {
        self.fetchNotes()
    }
    
    func addNote() {
        self.notes.insert(Note(), at: 0)
    }
    
    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            self.deleteNote(id: notes[index].id)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.notes.move(fromOffsets: source, toOffset: destination)
        // TODO: save order in db
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}
