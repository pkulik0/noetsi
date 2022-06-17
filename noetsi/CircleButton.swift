//
//  CircleButton.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

struct CircleButton<Content: View>: View {
    let imageName: String
    let destination: () -> Content?
    let onClick: () -> Void

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            Image(systemName: imageName)
                .font(.title)
                .padding()
                .background(Color.secondary)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
        .simultaneousGesture(TapGesture().onEnded({
            onClick()
        }))
        .buttonStyle(.plain)
    }
}
