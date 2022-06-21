//
//  LocalAuthView.swift
//  noetsi
//
//  Created by pkulik0 on 16/06/2022.
//

import SwiftUI
import LocalAuthentication

struct LocalAuthView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isUnlocked: Bool
    
    var imageName: String {
        switch(LAContext().biometryType){
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.fill"
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.6)
            
            VStack {
                Button {
                    authenticate()
                } label: {
                    VStack {
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                            .padding()
                        Text("Unlock noetsi")
                            .font(.body.bold())
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
                
                Button(action: firestoreManager.signOut) {
                    Label("Sign Out", systemImage: "person.crop.circle.badge.xmark")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.secondary)
                }
                .padding()
                .buttonStyle(.plain)
                .opacity(0.75)
            }
        }
        .onAppear {
            authenticate()
        }
    }
    
    func authenticate() {
        let context = LAContext()

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your notes") { authResult, _ in
                if authResult {
                    withAnimation {
                        isUnlocked = true
                    }
                }
            }
        }
    }
}
