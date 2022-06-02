//
//  TagView.swift
//  noetsi
//
//  Created by qurrie on 02/06/2022.
//

import SwiftUI

struct TagView: View {
    let noteID: Int
    let tagID: Int
    
    @EnvironmentObject var firestoreManager: FirestoreManager

    var body: some View {
        HStack(spacing: 0) {
            Text("#")
                .bold()
                .foregroundColor(.secondary)
            TextField("Tag", text: $firestoreManager.notes[noteID].tags[tagID], onEditingChanged: { focused in
                if !focused && firestoreManager.notes[noteID].tags[tagID].isEmpty {
                    // TODO: remove the tag
                }
            })
                .fixedSize()
        }
        .padding(10)
        .background(Capsule().stroke(.secondary, lineWidth: 3))
    }
}

