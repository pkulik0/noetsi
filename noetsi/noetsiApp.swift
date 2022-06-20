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
        
        if ProcessInfo.processInfo.environment["unit_testing"] == "true" {
            print("Running Firestore locally.")

            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false

            Firestore.firestore().settings = settings
        }
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
