//
//  AuthView.swift
//  noetsi
//
//  Created by qurrie on 16/06/2022.
//

import SwiftUI
import LocalAuthentication

struct AuthView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @AppStorage("enableAuth") private var enableAuth = false
    @Environment(\.dismiss) private var dismiss
    @Binding var isUnlocked: Bool

    var body: some View {
        VStack {
            Button {
                authenticate()
            } label: {
                Label("Unlock notes", systemImage: "lock.fill")
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            }
            .padding()
            .background(Capsule().strokeBorder(Color.accentColor, lineWidth: 3))
            
            Button("Sign out") {
                firestoreManager.signOut()
                enableAuth = false
                dismiss()
            }
            .font(.headline)
            .padding()
            .opacity(0.8)
        }
        .onAppear {
            authenticate()
        }
    }
    
    func authenticate() {
        if enableAuth == false {
            isUnlocked = true
            return
        }

        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your notes") { authResult, _ in
                if authResult {
                    withAnimation {
                        isUnlocked = true
                        dismiss()
                    }
                }
            }
        }
    }
}
