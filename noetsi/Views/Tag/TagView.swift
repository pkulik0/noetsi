//
//  TagView.swift
//  noetsi
//
//  Created by pkulik0 on 02/06/2022.
//

import SwiftUI

/// Displays a single tag inside a capsule-shaped stroke border.
struct TagView: View {
    
    /// The text to display inside the view
    let tag: String
    
    /// The view's foreground color. 
    var color: Color = .secondary
    
    var body: some View {
        HStack(spacing: 0) {
            Text("#")
                .bold()
                .foregroundColor(color)
            Text(tag)
        }
        .padding(10)
        .background(Capsule().strokeBorder(color, lineWidth: 3).opacity(0.75))
    }
}

