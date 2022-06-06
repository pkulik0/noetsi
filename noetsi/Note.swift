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
    @Published var timestamp: Int
    @Published var colorName: String
    
    var color: Color {
        get {
            Color.noteColorByName[self.colorName] ?? .white
        }
        set(newColor) {
            colorName = newColor.description
        }
    }

    init(id: String) {
        let randomColor = Color.noteColors.randomElement() ?? .blue
        
        self.id = id
        self.title = ""
        self.body = ""
        self.tags = []
        self.timestamp = Int(Date().timeIntervalSince1970)
        self.colorName = randomColor.description
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
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
