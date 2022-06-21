//
//  MainView.swift
//  noetsi
//
//  Created by pkulik0 on 30/05/2022.
//

import SwiftUI
import LocalAuthentication

///
/// Root view for authorized users.
///
/// ``MainView`` allows users to switch between the application's tabs:
/// - ``NoteListView``
/// - ``TagListView``
/// - ``SettingsView``
///
/// Displays ``AuthView`` if local authentication is enabled and the application has not been unlocked.
///
struct MainView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isUnlocked = false
    @State private var selectedTab = "list"

    var body: some View {
        TabView(selection: $selectedTab) {
            NoteListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag("list")
            
            TagListView()
                .tabItem {
                    Label("Tags", systemImage: "number")
                }
                .tag("tags")
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag("settings")
        }
        .localAuthenticationDialog(isUnlocked: $isUnlocked)
    }
}
