//
//  FirestoreManager.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import Firebase

class FirestoreManager: ObservableObject {
    @Published var notes: [Note] = []
    
    let db = Firestore.firestore()

    var uid: String? {
        if let user = Auth.auth().currentUser {
            return String(user.uid)
        }
        return nil
    }
    
    init() {
        fetchNotes()
    }
    
    func writeNote(id: Int) {
        guard let uid = uid else {
            return
        }

        let note = notes[id]
        db.collection(uid).document(note.id).setData(["title": note.title, "body": note.body, "tags": note.tags, "color": note.color], merge: true) { error in
            if let error = error {
                print("Could not update note \(id): \(error.localizedDescription)")
            }
        }
    }
    
    func fetchNotes() {
        guard let uid = uid else { 
            return
        }

        db.collection(uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                // TODO: handle better?
                print(error.localizedDescription)
                return
            }
            for document in querySnapshot!.documents {
                var note: Note = Note(id: document.documentID, title: "", body: "", tags: [], color: "")

                note.title = document.data()["title"] as? String ?? "Unknown title"
                note.body = document.data()["body"] as? String ?? "Unknown content"
                note.tags = document.data()["tags"] as? [String] ?? []
                note.color = document.data()["color"] as? String ?? "white"
                
                self.notes.append(note)
            }
        }
    }
}
