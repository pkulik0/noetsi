//
//  ListNoteRowView.swift
//  noetsi
//
//  Created by qurrie on 01/06/2022.
//

import SwiftUI

struct ListNoteRowView: View {
    let note: Note
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(note.title)
                    .font(.headline)
                HStack {
                    ForEach(note.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            Text(note.body)
                .font(.body)
                .frame(maxHeight: 100)
        }
    }
}

struct ListNoteRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListNoteRowView(note: Note(id: "", title: "Note0", body: "Body of note0", tags: ["tag0", "nsfw"], color: "red"))
    }
}
