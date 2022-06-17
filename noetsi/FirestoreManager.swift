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
    @Published var layout: [String] = []
    @Published var status: FirestoreStatus = .loading
    
    private let db = Firestore.firestore()
    private var buffer: [Note] = []
    
    init() {
        fetchData()
    }

    var uid: String? {
        if let user = Auth.auth().currentUser {
            return String(user.uid)
        }
        return nil
    }

    func writeNote(note: Note) {
        guard let uid = uid else {
            status = .no_user
            return
        }
        
        let batch = db.batch()

        let noteDocument = db.collection(uid).document(note.id)
        batch.setData(["title": note.title, "body": note.body, "tags": note.tags, "timestamp": note.timestamp, "color": note.color.description, "pattern": ["type": note.pattern.type.rawValue, "size": note.pattern.size], "checklist": convertChecklist(checklist: note.checklist)], forDocument: noteDocument, merge: true)
        
        let userData = db.collection(uid).document("userData")
        batch.setData(["layout": layout], forDocument: userData, merge: true)
        
        batch.commit() { error in
            if let error = error {
                print("Could not write note \(note.id): \(error.localizedDescription)")
            } else {
                print("Note \(note.id) written")
            }
        }
    }
    
    func writeLayout() {
        guard let uid = uid else {
            status = .no_user
            return
        }

        db.collection(uid).document("userData").setData(["layout": layout], merge: true) { error in
            if let error = error {
                print("Could not update layout: \(error.localizedDescription)")
            } else {
                print("Layout updated")
            }
        }
    }

    func deleteNote(id: String) {
        guard let uid = uid else {
            status = .no_user
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
                self.layout.remove(at: index)
                
                self.writeLayout()
            }
        }
    }
    
    func parseUserData(document: QueryDocumentSnapshot) {
        layout = document.data()["layout"] as? [String] ?? []
    }
    
    func parseNote(document: QueryDocumentSnapshot) {
        let note: Note = Note(id: document.documentID)

        note.title = document.data()["title"] as? String ?? "Unknown title"
        note.body = document.data()["body"] as? String ?? "Unknown content"
        note.tags = document.data()["tags"] as? [String] ?? []
        note.timestamp = document.data()["timestamp"] as? Int ?? 0
        
        let colorName = document.data()["color"] as? String ?? Color.noteColors[0].description
        note.color = Color.noteColorByName[colorName] ?? Color.noteColors[0]
        
        let patternData = document.data()["pattern"] as? [String: Any] ?? [:]
        note.pattern.type = Note.PatternType(rawValue: patternData["type"] as? Int ?? 0) ?? .None
        note.pattern.size = patternData["size"] as? Double ?? 20.0
        
        let checklistItems = document.data()["checklist"] as? [String] ?? []
        for item in checklistItems {
            let isChecked = (item.first ?? "0" == "1") ? true : false
            let text: String = String(item[item.index(after: item.startIndex)...])
            note.checklist.append(Note.ChecklistItem(text: text, isChecked: isChecked))
        }
        
        self.buffer.append(note)
    }
    
    func fetchData() {
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
            
            self.buffer = []

            for document in querySnapshot!.documents {
                if document.documentID == "userData" {
                    self.parseUserData(document: document)
                } else {
                    self.parseNote(document: document)
                }
            }
            
            self.buffer.sort { note1, note2 in
                (self.layout.firstIndex(where: { $0 == note1.id}) ?? Int.max) < (self.layout.firstIndex(where: { $0 == note2.id}) ?? Int.max)
            }

            self.notes = self.buffer
            self.status = .success
        }
    }
    
    func convertChecklist(checklist: [Note.ChecklistItem]) -> [String] {
        var firebaseChecklist: [String] = []
        for item in checklist {
            if item.text.isEmpty {
                continue
            }
            firebaseChecklist.append("\(item.isChecked ? "1" : "0")\(item.text)")
        }
        return firebaseChecklist
    }
    
    func addNote() {
        let note = Note()
        self.notes.insert(note, at: 0)
        self.layout.insert(note.id, at: 0)
    }
    
    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            self.deleteNote(id: notes[index].id)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.notes.move(fromOffsets: source, toOffset: destination)
        self.layout.move(fromOffsets: source, toOffset: destination)

        self.writeLayout()
        UIImpactFeedbackGenerator().impactOccurred()
    }
    
    func signOut() {
        @AppStorage("enableAuth") var enableAuth = false
        do {
            try Auth.auth().signOut()
            self.notes = []
            self.buffer = []
            self.layout = []
            self.status = .no_user
            enableAuth = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func signUp(email: String, password: String, onFinished: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            onFinished(error)
        }
    }
    
    func signIn(email: String, password: String, onFinished: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            onFinished(error)
        }
    }
}
