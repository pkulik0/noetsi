//
//  TagView.swift
//  noetsi
//
//  Created by qurrie on 02/06/2022.
//

import SwiftUI

struct TagView: View {
    let tag: String
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

