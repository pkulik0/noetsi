//
//  MainView.swift
//  noetsi
//
//  Created by pkulik0 on 30/05/2022.
//

import SwiftUI
import LocalAuthentication

struct MainView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("enableAuth") private var enableAuth = false
    
    @State private var showNewNote = false
    @State private var showOptions = false
    @State private var showAuthError = false
    @State private var isUnlocked = false

    var body: some View {
        NavigationView {
            NoteListView()
                .navigationTitle("noetsi")
        }
        .toolbar {
            Button {
                showOptions.toggle()
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        .confirmationDialog("More", isPresented: $showOptions) {
            Button("\(enableAuth ? "Unlock" : "Lock") noetsi", action: enableLA)
            Button("Sign out", role: .destructive, action: signOut)
        }
        .alert("Cannot enable authentication", isPresented: $showAuthError, actions: {
            Button("OK") {}
        }, message: {
            Text("Your device  does not support local authentication.")
        })
        .authenticationDialog(isUnlocked: $isUnlocked)
    }
    
    func enableLA() {
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            enableAuth.toggle()
        } else {
            enableAuth = false
            showAuthError = true
        }
    }

    func signOut() {
        firestoreManager.signOut()
        dismiss()
    }
}
