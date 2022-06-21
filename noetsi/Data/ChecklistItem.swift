//
//  ChecklistItem.swift
//  noetsi
//
//  Created by pkulik0 on 21/06/2022.
//

/// Represents an entry in a checklist.
struct ChecklistItem: Equatable, Codable {
    
    /// Text displayed next to the toggle.
    var text: String
    
    /// Toggles the item state.
    var isChecked: Bool
}
