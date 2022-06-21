//
//  FirestoreManager.swift
//  noetsi
//
//  Created by pkulik0 on 30/05/2022.
//

import Firebase
import SwiftUI

///
/// Manages the connection between the application and Google Firebase.
///
/// FirestoreManager is the main and only entry point of data to the appication in the current version of noetsi.
/// It provides functions to write and delete ``Note``, fetch user's notes and keeps track of their layout.
/// This class also handles authenticating the user with FirebaseAuth.
///
/// When used with the environment variable "unit_testing" set to "true" it connects to a local instance.
///
class FirestoreManager: ObservableObject {

    /// User's notes fetched from database.
    @Published var notes: [Note] = []
    
    /// Buffer used to make sure the user always sees notes on the screen.
    private var buffer: [Note] = []
    
    ///
    /// Layout of the notes in the user interface.
    ///
    /// Each note is represented by its unique identifer.
    ///
    @Published var layout: [String] = []
    
    /// Connection to the Firestore Database.
    private let db = Firestore.firestore()

    /// Map of all the application's pending notifications.
    private var reminders: [String: UNNotificationRequest?] = [:]
    
    /// Value used for detecting if the application is currently running automated tests.
    private let debugMode: Bool = ProcessInfo.processInfo.environment["unit_testing"] == "true"
    
    /// Initialize ``FirestoreManager`` by fetching data. Enables debugMode if the app is running unit tests.
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

    ///
    /// Wrapper around FirebaseAuth's user identifier.
    ///
    /// Used as an authentication guard at the beginning of functions interracting with the database.
    /// Allows to circumvent authentication during automated testing.
    ///
    var uid: String? {
        if debugMode {
            return "testUserID"
        }

        if let user = Auth.auth().currentUser {
            return String(user.uid)
        }

        return nil
    }

    ///
    /// Writes ``Note`` to the database and updates the layout.
    /// - Parameter note: the ``Note`` to write.
    ///
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
    
    /// Write a user's layout to the database.
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

    ///
    /// Delete a ``Note`` from the database.
    /// - Parameter id: the identifier of the ``Note`` to delete.
    ///
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
    
    /// Parse document data received from Firestore as a layout of notes.
    private func parseUserData(document: QueryDocumentSnapshot) {
        layout = document.data()["layout"] as? [String] ?? []
    }
    
    /// Parse document data received from Firestore as ``Note``.
    private func parseNote(document: QueryDocumentSnapshot) {
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
    
    ///
    /// Find the application's pending notifications.
    ///
    /// Save all the application's notification requests in a map to look through them efficiently during assembly of a ``Note``.
    ///
    private func fetchReminders() {
        reminders = [:]
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                self.reminders[request.identifier] = request
            }
        }
    }
    
    ///
    /// Fetch data corresponding to a ``uid`` from the database.
    ///
    /// Requests and parses all of user's notes and their account's additional data.
    ///
    /// Works on a buffer to avoid overwritten data currently displayed to the user.
    ///
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
    
    ///
    /// Convert a checklist from the format used by noetsi iOS to the database's format.
    ///
    /// Convert an array of ``Note.ChecklistItem`` to the format of checklists used in Firestore.
    ///
    /// - "abc" set to *false* becomes 0abc
    /// - "123" set to *true* becomes 1123
    ///
    /// This method of data representation has been chosen because it provides good balance between ease of representation and use in NoSQL and Swift.
    ///
    /// - Returns: A checklist in the database's format.
    ///
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
    
    ///
    /// Create a new ``Note`` without writing it to the database.
    ///
    /// Create a ``Note`` and save it in ``notes`` and ``layout``.
    ///
    func addNote() {
        let note = Note()
        self.notes.insert(note, at: 0)
        self.layout.insert(note.id, at: 0)
    }
    
    ///
    /// Delete notes from ``notes`` at offsets.
    /// - Parameter offsets: positions at which notes will be deleted.
    ///
    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            self.deleteNote(id: notes[index].id)
        }
    }
    
    ///
    /// Move notes located at source to destination and write changes to the database.
    ///
    /// Move entries corresponding to the elements in ``notes`` and ``layout``, write changes to the database and generate feedback.
    /// - Parameter source: origins of the elements.
    /// - Parameter destination: position to which the elements should be moved.
    ///
    func move(from source: IndexSet, to destination: Int) {
        self.notes.move(fromOffsets: source, toOffset: destination)
        self.layout.move(fromOffsets: source, toOffset: destination)

        self.writeLayout()
        UIImpactFeedbackGenerator().impactOccurred()
    }
    
    /// Sign out user from FirebaseAuth and disable local authentication.
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
    
    /// Try to create a new account using FirebaseAuth.
    func signUp(email: String, password: String, onFinished: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            onFinished(error)
        }
    }
    
    /// Try to sign in with existing user's credentials.
    func signIn(email: String, password: String, onFinished: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            onFinished(error)
        }
    }
}
