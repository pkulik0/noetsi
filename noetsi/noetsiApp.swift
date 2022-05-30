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
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                MainView()
            } else {
                WelcomeView()
            }
        }
    }
}
