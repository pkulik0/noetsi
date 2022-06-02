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
        NavigationView {
            VStack {
                List(Array(firestoreManager.notes.enumerated()), id: \.offset) { noteIndex, note in
                    ZStack {
                        NavigationLink(destination: NoteView(noteID: noteIndex)) {}.opacity(0)
                        ListNoteRowView(note: note)
                            .shadow(radius: 5)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Notes")
            .toolbar {
                Button("Sign out") {
                    do {
                        try Auth.auth().signOut()
                        changeView = true
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
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
