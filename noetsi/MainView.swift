//
//  MainView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI
import Firebase

struct MainView: View {
    @State private var changeView = false
    
    @EnvironmentObject var firestoreManager: FirestoreManager

    var body: some View {
        // TODO: This view :)
        NavigationView {
            VStack {
                List(firestoreManager.notes) { note in
                    NavigationLink {
                        Text(note.body)
                            .font(.title.bold())
                    } label: {
                        ListRowView(note: note)
                    }

                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Notes")
        }
        .fullScreenCover(isPresented: $changeView) {
            WelcomeView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct ListRowView: View {
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
                            .foregroundColor(.red)
                    }
                }
            }
            Spacer()
            Text(note.body)
                .font(.body)
        }
    }
}
