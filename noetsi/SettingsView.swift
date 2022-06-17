//
//  SettingsView.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @AppStorage("enableAuth") private var enableAuth = false

    @State private var showAuthError = false
    
    private var versionString: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        return "Version \(appVersion)"
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image("icon_max")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding([.vertical, .trailing], 5)

                        VStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                Text("noetsi")
                                Text(" by pkulik0")
                                    .foregroundColor(.secondary)
                            }
                            .font(.headline)

                            Text(versionString)
                                .font(.subheadline)
                        }
                    }
                } header: {
                    Text("App Information")
                }

                Section {
                    Toggle("\(enableAuth ? "Unlock" : "Lock") noetsi", isOn: $enableAuth)
                        .toggleStyle(.switch)
                } header: {
                    Text("Device settings")
                }
                
                Section {
                    Button("Change password") {}
                    Button("Remove my account") {}
                    Button("Sign Out", role: .destructive, action: firestoreManager.signOut)
                } header: {
                    Text("Account settings")
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Cannot enable authentication", isPresented: $showAuthError, actions: {
            Button("OK") {}
        }, message: {
            Text("Your device  does not support local authentication.")
        })
    }
    
    func enableLA() {
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            enableAuth.toggle()
        } else {
            enableAuth = false
            showAuthError = true
        }
    }
}
