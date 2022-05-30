//
//  FirestoreManager.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import Firebase

class FirestoreManager: ObservableObject {
    @Published var notes: [Note] = []

    var uid: String {
        if let user = Auth.auth().currentUser {
            return String(user.uid)
        }
        return "-1"
    }
    
    init() {
        fetchNotes()
    }
    
    func fetchNotes() {
        let db = Firestore.firestore()
        
        db.collection(uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                // TODO: handle better?
                print(error.localizedDescription)
                return
            }
            for document in querySnapshot!.documents {
                var note: Note = Note(id: document.documentID, title: "", body: "", tags: [])
                
                note.title = document.data()["title"] as? String ?? "Unknown title"
                note.body = document.data()["body"] as? String ?? "Unknown content"
                note.tags = document.data()["tags"] as? [String] ?? []
                
                self.notes.append(note)
                print("\(note)")
            }
        }
    }
}
