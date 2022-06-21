//
//  NoteColor.swift
//  noetsi
//
//  Created by pkulik0 on 03/06/2022.
//

import SwiftUI

extension Color {
    /// Background colors supported by ``Note``
    public static let noteColors: [Color] = [.red, .orange, .green, .blue, .purple, .secondary]

    /// Map with noteColors as keys and their name as the value.
    public static let noteColorByName: [String: Color] = {
        var result: [String: Color] = [:]
        for color in noteColors {
            result[color.description] = color
        }
        return result
    }()
}
