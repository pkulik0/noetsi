//
//  TagView.swift
//  noetsi
//
//  Created by qurrie on 02/06/2022.
//

import SwiftUI

struct TagView: View {
    let tag: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text("#")
                .bold()
                .foregroundColor(.secondary)
            Text(tag)
        }
        .padding(10)
        .background(Capsule().strokeBorder(.secondary, lineWidth: 3))
    }
}

