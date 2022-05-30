//
//  ContentView.swift
//  noetsi
//
//  Created by qurrie on 29/05/2022.
//

import SwiftUI
import Firebase

struct WelcomeView: View {
    @State private var email = ""
    @State private var password = ""
    
    @State private var colorsSwitched = true
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var authSuccess = false
    
    var isValid: Bool {
        return email.contains("@") && email.count > 5 && !password.isEmpty
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("welcome to ")
                    .font(.title.bold())
                Text("noetsi")
                    .font(.title.bold())
                    .foregroundColor(colorsSwitched ? .blue : .red)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill())
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
                    Button("sign up", action: signup)
                        .disabled(!isValid)
                        .font(.title.bold())
                        .foregroundColor(isValid ? Color(uiColor: .label) : Color(uiColor: .label).opacity(0.25))
                        .padding(10)
                    
                    Button("sign in", action: signin)
                        .disabled(!isValid)
                        .font(.title.bold())
                        .foregroundColor(isValid ? (colorsSwitched ? .red : .blue) : .white)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill())
                        .opacity(isValid ? 1.0 : 0.5)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: .constant(authSuccess), content: {
            MainView()
        })
        .alert("Error", isPresented: $showingAlert, actions: {
            Button("OK") {}
        }, message: {
            Text(alertMessage)
        })
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 30...60), repeats: true) { timer in
                colorsSwitched.toggle()
            }
        }
    }
    
    func handleAuthResult(error: Error?) {
        if let error = error {
            alertMessage = error.localizedDescription
            showingAlert = true
        } else {
            authSuccess = true
        }
    }
    
    func signup() {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            handleAuthResult(error: error)
        }
    }
    
    func signin() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            handleAuthResult(error: error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
