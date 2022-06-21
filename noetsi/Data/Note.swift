//
//  Note.swift
//  noetsi
//
//  Created by pkulik0 on 30/05/2022.
//

import SwiftUI

/// Represents the base of the application - a Note.
class Note: ObservableObject, Identifiable, Equatable, CustomStringConvertible {
    
    /// Represents ``Note``'s background pattern.
    struct Pattern: Equatable {
        /// The selected type of pattern
        var type: PatternType
        
        /// The distance between lines of the pattern.
        var size: Double
    }
    
    /// Used to switch between available types of ``Note.Pattern``.
    enum PatternType: Int {
        /// No pattern
        case None
        /// Horizontal lines
        case Lines
        /// Horizontal and vertical lines
        case Grid
    }
    
    ///
    /// The ``Note``'s unique UUID identifier
    ///
    /// Every ``Note`` has a unique identifier under which it is kept both in the application and the database.
    ///
    @Published var id: String
    
    /// The title displayed to the user.
    @Published var title: String
    
    /// The main text field of ``Note``.
    @Published var body: String
    
    ///
    /// The ``Note``'s tags kept in an array of type String.
    ///
    /// Every ``Note`` has an unlimited amount of tags of type String.
    /// They can be used to filter notes in the application.
    ///
    @Published var tags: [String]
    
    ///
    /// The ``Note``'s background color.
    ///
    /// Kept as a SwiftUI Color and converted into text when saved in the database.
    ///
    @Published var color: Color
    
    /// Pattern displayed on top of  the ``Note``'s ``color``.
    @Published var pattern: Pattern
    
    /// Represents an entry in a checklist.
    struct ChecklistItem: Equatable, Codable {
        var text: String
        var isChecked: Bool
    }
    
    /// Checklist attached to ``Note``.
    @Published var checklist: [ChecklistItem]
    
    /// Optional reminder attached to the ``Note`` that fires at a user-defined time.
    @Published var reminder: UNNotificationRequest?

    /// UNIX timestamp saved at the time of the ``Note``'s creation
    var timestamp: Int
    
    /// Used to queue the ``Note`` for removal from within a view that displays it.
    var deleteMe: Bool
    
    /// String representation of the object.
    var description: String { id }
    
    /// String used for sharing the ``Note`` with somebody.
    var shareable: String {
        """
        noetsi note: "\(title.isEmpty ? "Untitled" : title)"
        
        \(body)
        """
    }
    
    /// ``body`` with maximum 1 blank line between text.
    var bodyCompact: String {
        var result = body
        // Allow max 1 blank line between text
        while result != result.replacingOccurrences(of: "\n\n\n", with: "\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n")
        }
        return result
    }
    
    /// ``body`` with a line limit of 1.
    var bodyInline: String {
        bodyCompact.replacingOccurrences(of: "\n", with: " ")
    }

    /// Checks if fields that are of importance to the user are empty.
    var isEmpty: Bool {
        title.isEmpty && body.isEmpty && tags.isEmpty && checklist.isEmpty && reminder == nil
    }
    
    /// Base case initializer.
    init(id: String, title: String, body: String, tags: [String], timestamp: Int, color: Color, pattern: Pattern, checklist: [ChecklistItem], notificationRequest: UNNotificationRequest?) {
        self.id = id
        self.title = title
        self.body = body
        self.tags = tags
        self.color = color
        self.pattern = pattern
        self.timestamp = timestamp
        self.checklist = checklist
        self.reminder = notificationRequest
        
        self.deleteMe = false
    }

    /// Initializer for building a ``Note`` from Firestore data.
    convenience init(id: String) {
        let randomColor = Color.noteColors.randomElement() ?? .blue
        self.init(id: id, title: "", body: "", tags: [], timestamp: Int(Date().timeIntervalSince1970), color: randomColor, pattern: Pattern(type: .None, size: 20), checklist: [], notificationRequest: nil)
    }
    
    /// Initializer for placeholder objects that will never be saved.
    convenience init() {
        self.init(id: UUID().uuidString)
    }
    
    ///
    /// Implentation of the Equatable Protocol
    ///
    /// This function is used to detect changes in a note, therefore all important fields must be checked.
    ///
    static func == (lhs: Note, rhs: Note) -> Bool {
        (lhs.id == rhs.id) && (lhs.title == rhs.title) && (lhs.body == rhs.body) && (lhs.tags == rhs.tags) && (lhs.timestamp == rhs.timestamp) && (lhs.color == rhs.color) && (lhs.pattern == rhs.pattern) && (lhs.checklist == rhs.checklist) && (lhs.reminder == rhs.reminder)
    }
    
    /// Create a second ``Note`` object with the same data as this one.
    func copy() -> Note {
        let copy = Note(id: self.id, title: self.title, body: self.body, tags: self.tags, timestamp: self.timestamp, color: self.color, pattern: self.pattern, checklist: self.checklist, notificationRequest: self.reminder)
        return copy
    }
}
