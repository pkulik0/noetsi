//
//  ListNoteRowView.swift
//  noetsi
//
//  Created by qurrie on 01/06/2022.
//

import SwiftUI

struct ListNoteRowView: View {
    let note: Note
    
    @EnvironmentObject private var firestoreManager: FirestoreManager
    
    private var noteColor: Color {
        Color.noteColorByName[note.color]?.opacity(0.5) ?? .white
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(note.title)
                    .font(.headline)
                Image(systemName: "chevron.right")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
    
            Text(note.body)
                .font(.body)
                .padding(.horizontal)
                .lineLimit(5)

            TagListView(noteID: firestoreManager.notes.firstIndex(where: { element in
                note.id == element.id
            }) ?? 0)
        }
        .padding()
        .background(noteColor.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ListNoteRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListNoteRowView(note: Note(id: "", title: "Note0", body: "Body note0", tags: ["tag0"], color: "blue"))
    }
}
