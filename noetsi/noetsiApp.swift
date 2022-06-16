//
//  noetsiApp.swift
//  noetsi
//
//  Created by qurrie on 29/05/2022.
//

import SwiftUI
import Firebase

@main
struct noetsiApp: App {
    @StateObject private var firestoreManager = FirestoreManager()
    @AppStorage("enableAuth") private var enableAuth = false
    @State private var isUnlocked = false

    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            Group {
                if Auth.auth().currentUser != nil {
                    if enableAuth && !isUnlocked {
                        AuthView(isUnlocked: $isUnlocked)
                    } else {
                        MainView()
                    }
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(firestoreManager)
        }
    }
}
