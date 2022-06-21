//
//  Pattern.swift
//  noetsi
//
//  Created by pkulik0 on 21/06/2022.
//

/// Represents ``Note``'s background pattern.
struct Pattern: Equatable, Codable {
    
    /// Used to switch between available types of ``Pattern``.
    enum PatternType: Int, Codable {
        /// No pattern
        case None
        /// Horizontal lines
        case Lines
        /// Horizontal and vertical lines
        case Grid
    }

    /// The selected type of pattern
    var type: PatternType
    
    /// The distance between lines of the pattern.
    var size: Double
}
