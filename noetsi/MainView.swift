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
    
    let firestoreManager = FirestoreManager()

    var body: some View {
        // TODO: This view :)
        VStack {
            Text("Hello, \(Auth.auth().currentUser!.email ?? "email")")
            Button("Sign out") {
                do {
                    try Auth.auth().signOut()
                    changeView = true
                } catch {
                    print(error.localizedDescription)
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
