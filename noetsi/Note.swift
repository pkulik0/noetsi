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
    @Published var color: Color
    
    @Published var checklist: [String: Bool]?
    @Published var images: [Image]?
    @Published var location: CLLocation?
    
    var timestamp: Int
    var deleteMe: Bool

    var isEmpty: Bool {
        title.isEmpty && body.isEmpty && tags.isEmpty && checklist == nil && images == nil
    }
    
    init(id: String, title: String, body: String, tags: [String], timestamp: Int, color: Color) {
        self.id = id
        self.title = title
        self.body = body
        self.tags = tags
        self.color = color
        self.timestamp = timestamp
        
        self.deleteMe = false
    }

    convenience init(id: String) {
        let randomColor = Color.noteColors.randomElement() ?? .blue
        self.init(id: id, title: "", body: "", tags: [], timestamp: Int(Date().timeIntervalSince1970), color: randomColor)
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        (lhs.id == rhs.id) && (lhs.title == rhs.title) && (lhs.body == rhs.body) && (lhs.tags == rhs.tags) && (lhs.timestamp == rhs.timestamp) && (lhs.color == rhs.color)
    }
    
    func copy() -> Note {
        let copy = Note(id: self.id, title: self.title, body: self.body, tags: self.tags, timestamp: self.timestamp, color: self.color)
        return copy
    }
}
