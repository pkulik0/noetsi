//
//  noetsiApp.swift
//  noetsi
//
//  Created by pkulik0 on 29/05/2022.
//

import SwiftUI
import Firebase

@main
struct noetsiApp: App {
    @StateObject private var firestoreManager = FirestoreManager()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if Auth.auth().currentUser != nil {
                    MainView()
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(firestoreManager)
        }
    }
}
