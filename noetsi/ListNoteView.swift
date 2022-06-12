//
//  ListNoteView.swift
//  noetsi
//
//  Created by qurrie on 01/06/2022.
//

import SwiftUI

struct ListNoteView: View {
    @Binding var note: Note

    private var bodyPlaceholder: String {
        if note.body.isEmpty {
            return "Empty"
        }
        return ""
    }
    
    private var titlePlaceholder: String {
        if note.title.isEmpty {
            return "Untitled"
        }
        return ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(titlePlaceholder)\(note.title)")
                    .font(.headline)
                    .foregroundColor(titlePlaceholder.count > 0 ? .secondary : .primary)
                Image(systemName: "chevron.right")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
    
            Text("\(bodyPlaceholder)\(note.body)")
                .font(.body)
                .padding(10)
                .lineLimit(5)
                .foregroundColor(bodyPlaceholder.count > 0 ? .secondary : .primary)
            
            if !note.checklist.isEmpty {
                Text("+ Checklist (\(note.checklist.count))")
                    .font(.caption)
            }

            TagListView(note: $note, showHeader: false)
        }
        .padding()
        .background(NoteBackground(color: note.color, pattern: note.pattern))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
