//
//  NoteColorExtension.swift
//  noetsi
//
//  Created by qurrie on 03/06/2022.
//

import SwiftUI

extension Color {
    public static let noteColors: [Color] = [.red, .orange, .green, .blue, .purple, .secondary]

    public static let noteColorByName: [String: Color] = {
        var result: [String: Color] = [:]
        for color in noteColors {
            result[color.description] = color
        }
        return result
    }()
}
