//
//  noetsiApp.swift
//  noetsi
//
//  Created by pkulik0 on 29/05/2022.
//

import SwiftUI
import Firebase

///
/// The application's entry point.
///
/// ``noetsiApp`` redirects the user to either ``MainView`` or ``WelcomeView`` depending on their authentication status.
///
@main
struct noetsiApp: App {
    @StateObject private var firestoreManager = FirestoreManager()
    
    /// Configure Firebase during start up.
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
