//
//  ContentView.swift
//  noetsi
//
//  Created by qurrie on 29/05/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    
    @State private var accentColors: [Color] = [.red, .blue, .pink, .cyan, .green, .yellow]

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("Welcome to ")
                    .font(.title.bold())
                Text("noetsi")
                    .font(.title.bold())
                    .foregroundColor(accentColors.randomElement()!)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill())
            }
            
                
            VStack {
                TextField("Username", text: $username)
                    .font(.headline)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill().opacity(0.3))
                    .padding(.bottom)

                TextField("Password", text: $password)
                    .font(.headline)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill().opacity(0.3))
                    .onSubmit {
                        username = "k"
                    }
                    .padding(.bottom, 25)
                
                Button("Continue") { }
                    .font(.title.bold())
                    .foregroundColor(accentColors.randomElement()!)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill())
            }
            .padding()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
