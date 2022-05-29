//
//  ContentView.swift
//  noetsi
//
//  Created by qurrie on 29/05/2022.
//

import SwiftUI

struct WelcomeView: View {
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("welcome to ")
                    .font(.title.bold())
                Text("noetsi")
                    .font(.title.bold())
                    .foregroundColor(.red)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill())
            }
            
                
            VStack {
                TextField("username", text: $username)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(lineWidth: 5))
                    .padding(.bottom)

                SecureField("password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(lineWidth: 5))
                    .onSubmit {
                        username = "k"
                    }
                    .padding(.bottom, 25)
                
                Button("let me in") { }
                    .font(.title.bold())
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill())
            }
            .padding()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
