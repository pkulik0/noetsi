//
//  Note.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

class Note: ObservableObject, Identifiable, Equatable {
    @Published var id: String
    @Published var title: String
    @Published var body: String
    @Published var tags: [String]
    @Published var colorName: String
    
    var color: Color {
        Color.noteColorByName[self.colorName] ?? .white
    }
    
    init(id: String, title: String, body: String, tags: [String], colorName: String) {
        self.id = id
        self.title = title
        self.body = body
        self.tags = tags
        self.colorName = colorName
    }
    
    convenience init(title: String, body: String, tags: [String], colorName: String) {
        self.init(id: UUID().uuidString, title: title, body: body, tags: tags, colorName: colorName)
    }
    
    convenience init(id: String) {
        self.init(id: id, title: "", body: "", tags: [], colorName: "blue")
    }
    
    convenience init() {
        self.init(title: "", body: "", tags: [], colorName: "blue")
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.body == rhs.body && lhs.tags == rhs.tags && lhs.colorName == rhs.colorName
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
