//
//  ListNoteView.swift
//  noetsi
//
//  Created by qurrie on 01/06/2022.
//

import SwiftUI

struct ListNoteView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    
    let noteID: Int
    
    private var noteColor: Color {
        Color.noteColorByName[firestoreManager.notes[noteID].color]?.opacity(0.5) ?? .white
    }
    
    private var bodyPlaceholder: String {
        if firestoreManager.notes[noteID].body.isEmpty {
            return "Empty"
        }
        return ""
    }
    
    private var titlePlaceholder: String {
        if firestoreManager.notes[noteID].title.isEmpty {
            return "Untitled"
        }
        return ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(titlePlaceholder)\(firestoreManager.notes[noteID].title)")
                    .font(.headline)
                    .foregroundColor(titlePlaceholder.count > 0 ? .secondary : .primary)
                Image(systemName: "chevron.right")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
    
            Text("\(bodyPlaceholder)\(firestoreManager.notes[noteID].body)")
                .font(.body)
                .padding(10)
                .lineLimit(5)
                .foregroundColor(bodyPlaceholder.count > 0 ? .secondary : .primary)

            TagListView(noteID: noteID, showHeader: false)
        }
        .padding()
        .background(noteColor.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
