//
//  FirestoreManager.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import Firebase

enum UserStatus {
    case loading, success, failed, no_user
}

class FirestoreManager: ObservableObject {
    @Published var notes: [Note] = []
    @Published var status: UserStatus = .loading
    
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

        db.collection(uid).document(note.id).setData(["title": note.title, "body": note.body, "tags": note.tags, "timestamp": note.timestamp, "color": note.colorName], merge: true) { error in
            if let error = error {
                print("Could not write/update note \(note.id): \(error.localizedDescription)")
            } else {
                print("Note updated: \(note.id)")
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
            
            self.notes = []

            for document in querySnapshot!.documents {
                let note: Note = Note(id: document.documentID)

                note.title = document.data()["title"] as? String ?? "Unknown title"
                note.body = document.data()["body"] as? String ?? "Unknown content"
                note.tags = document.data()["tags"] as? [String] ?? []
                note.timestamp = document.data()["timestamp"] as? Int ?? 0
                note.colorName = document.data()["color"] as? String ?? "white"
                
                self.notes.append(note)
            }
            self.status = .success
        }
    }
}
