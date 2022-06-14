//
//  ContentView.swift
//  noetsi
//
//  Created by qurrie on 29/05/2022.
//

import SwiftUI
import Firebase

struct WelcomeView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @State private var feedback = UINotificationFeedbackGenerator()

    @State private var email = ""
    @State private var password = ""

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var noetsiText = "noetsi"
    
    @State private var authSuccess = false
    
    private let systemBackground = Color(uiColor: UIColor.systemBackground)
    
    private var isValid: Bool {
        return email.contains("@") && email.contains(".") && email.count > 5 && password.count > 7
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("welcome to ")
                    .font(.title.bold())
                Text(noetsiText)
                    .font(.title.bold())
                    .foregroundColor(systemBackground)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary))
                    .onLongPressGesture(minimumDuration: 1, maximumDistance: 10) {
                        
                    } onPressingChanged: { state in
                        if state {
                            noetsiText = "onteis"
                        } else {
                            noetsiText = "noetsi"
                        }
                    }
                    .animation(.default, value: noetsiText)
            }
            
                
            VStack {
                TextField("email", text: $email)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(lineWidth: 5))
                    .padding(.bottom)

                SecureField("password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(lineWidth: 5))
                    .padding(.bottom, 25)
                
                HStack {
                    Button("sign up") {
                        firestoreManager.signUp(email: email, password: password, onFinished: handleAuthResult)
                    }
                    .disabled(!isValid)
                    .font(.title.bold())
                    .foregroundColor(isValid ? .primary : .primary.opacity(0.25))
                    .padding(10)
                    
                    Button("sign in") {
                        firestoreManager.signIn(email: email, password: password, onFinished: handleAuthResult)
                    }
                    .disabled(!isValid)
                    .font(.title.bold())
                    .foregroundColor(isValid ? systemBackground : .white)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(isValid ? Color.primary : .primary.opacity(0.25)))
                }
                .animation(.easeInOut, value: isValid)
            }
            .padding()
            .onSubmit {
                if isValid {
                    firestoreManager.signIn(email: email, password: password, onFinished: handleAuthResult)
                }
            }
        }
        .fullScreenCover(isPresented: $authSuccess, content: {
            MainView()
        })
        .alert("Error", isPresented: $showingAlert, actions: {
            Button("OK") {}
        }, message: {
            Text(alertMessage)
        })
    }
    
    func handleAuthResult(error: Error?) {
        if let error = error {
            feedback.notificationOccurred(.error)
            alertMessage = error.localizedDescription
            showingAlert = true
        } else {
            feedback.notificationOccurred(.success)
            authSuccess = true
            firestoreManager.fetchData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
