//
//  FirestoreManager.swift
//  noetsi
//
//  Created by pkulik0 on 30/05/2022.
//

import Firebase
import SwiftUI

class FirestoreManager: ObservableObject {
    @Published var notes: [Note] = []
    @Published var layout: [String] = []
    
    private let db = Firestore.firestore()
    private var buffer: [Note] = []
    private var reminders: [String: UNNotificationRequest?] = [:]
    
    private let debugMode: Bool = ProcessInfo.processInfo.environment["unit_testing"] == "true"
    
    init() {
        if debugMode {
            print("Running Firestore locally.")

            let settings = db.settings
            settings.host = "localhost:8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false

            db.settings = settings
        }
        fetchData()
    }

    var uid: String? {
        if debugMode {
            return "testUserID"
        }

        if let user = Auth.auth().currentUser {
            return String(user.uid)
        }

        return nil
    }

    func writeNote(note: Note) {
        guard let uid = uid else {
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
            }
        }
    }
    
    func writeLayout() {
        guard let uid = uid else {
            return
        }

        db.collection(uid).document("userData").setData(["layout": layout], merge: true) { error in
            if let error = error {
                print("Could not update layout: \(error.localizedDescription)")
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
        
        note.reminder = reminders[note.id] ?? nil
        
        self.buffer.append(note)
    }
    
    func fetchReminders() {
        reminders = [:]
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                self.reminders[request.identifier] = request
            }
        }
    }
    
    func fetchData() {
        guard let uid = uid else {
            return
        }
        
        fetchReminders()

        db.collection(uid).getDocuments { (querySnapshot, error) in
            if let error = error {
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
            self.buffer = []
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
