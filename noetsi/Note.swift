//
//  Note.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI
import MapKit

class Note: ObservableObject, Identifiable, Equatable {
    @Published var id: String
    @Published var title: String
    @Published var body: String
    @Published var tags: [String]
    @Published var timestamp: Int
    @Published var colorName: String
    
    @Published var checklist: [String: Bool]?
    @Published var images: [Image]?
    @Published var location: CLLocation?
    
    var color: Color {
        get {
            Color.noteColorByName[self.colorName] ?? .white
        }
        set(newColor) {
            colorName = newColor.description
        }
    }
    
    init(id: String, title: String, body: String, tags: [String], timestamp: Int, colorName: String) {
        self.id = id
        self.title = title
        self.body = body
        self.tags = tags
        self.timestamp = timestamp
        self.colorName = colorName
    }

    convenience init(id: String) {
        let randomColor = Color.noteColors.randomElement() ?? .blue
        self.init(id: id, title: "", body: "", tags: [], timestamp: Int(Date().timeIntervalSince1970), colorName: randomColor.description)
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        (lhs.id == rhs.id) && (lhs.title == rhs.title) && (lhs.body == rhs.body) && (lhs.tags == rhs.tags) && (lhs.timestamp == rhs.timestamp) && (lhs.colorName == rhs.colorName)
    }
    
    func copy() -> Note {
        let copy = Note(id: self.id, title: self.title, body: self.body, tags: self.tags, timestamp: self.timestamp, colorName: self.colorName)
        return copy
    }
}

class NoteList: ObservableObject {
    @Published var notes: [Note]
    
    init(notes: [Note]) {
        self.notes = notes
    }
    
    convenience init() {
        self.init(notes: [])
    }
    
    func remove(at index: Int, firestoreManager: FirestoreManager) {
        firestoreManager.deleteNote(id: notes[index].id)
        notes.remove(at: index)
    }
}
