//
//  NoteColorExtension.swift
//  noetsi
//
//  Created by qurrie on 03/06/2022.
//

import SwiftUI

extension Color {
    public static var noteColors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange]

    public static var noteColorByName: [String: Color] {
        var result: [String: Color] = [:]
        for color in noteColors {
            result[color.description] = color
        }
        return result
    }
}
