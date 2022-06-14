//
//  Note.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

class Note: ObservableObject, Identifiable, Equatable {
    
    enum PatternType: Int {
        case None, Lines, Grid
    }

    struct Pattern: Equatable {
        var type: PatternType
        var size: Double
    }
    
    @Published var id: String
    @Published var title: String
    @Published var body: String
    @Published var tags: [String]
    
    @Published var color: Color
    @Published var pattern: Pattern
    
    struct ChecklistItem: Equatable, Codable {
        var text: String
        var isChecked: Bool
    }
    
    @Published var checklist: [ChecklistItem]
    
    var checklistFirebase: [[String:Bool]] {
        var firebaseChecklist: [[String:Bool]] = []
        for item in checklist {
            if item.text.isEmpty {
                continue
            }
            firebaseChecklist.append([item.text:item.isChecked])
        }
        return firebaseChecklist
    }

    var timestamp: Int
    var deleteMe: Bool
    
    var shareable: String {
        """
        noetsi note: "\(title.isEmpty ? "Untitled" : title)"
        
        \(body)
        """
    }

    var isEmpty: Bool {
        title.isEmpty && body.isEmpty && tags.isEmpty && checklist.isEmpty
    }
    
    init(id: String, title: String, body: String, tags: [String], timestamp: Int, color: Color, pattern: Pattern, checklist: [ChecklistItem]) {
        self.id = id
        self.title = title
        self.body = body
        self.tags = tags
        self.color = color
        self.pattern = pattern
        self.timestamp = timestamp
        self.checklist = checklist
        
        self.deleteMe = false
    }

    convenience init(id: String) {
        let randomColor = Color.noteColors.randomElement() ?? .blue
        self.init(id: id, title: "", body: "", tags: [], timestamp: Int(Date().timeIntervalSince1970), color: randomColor, pattern: Pattern(type: .None, size: 20), checklist: [])
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        (lhs.id == rhs.id) && (lhs.title == rhs.title) && (lhs.body == rhs.body) && (lhs.tags == rhs.tags) && (lhs.timestamp == rhs.timestamp) && (lhs.color == rhs.color) && (lhs.pattern == rhs.pattern) && (lhs.checklist == rhs.checklist)
    }
    
    func copy() -> Note {
        let copy = Note(id: self.id, title: self.title, body: self.body, tags: self.tags, timestamp: self.timestamp, color: self.color, pattern: self.pattern, checklist: self.checklist)
        return copy
    }
}
