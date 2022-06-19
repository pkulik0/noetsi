//
//  AuthViewModifier.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

struct AuthViewModifier: ViewModifier {
    @AppStorage("enableAuth") private var enableAuth = false
    @Binding var isUnlocked: Bool

    func body(content: Content) -> some View {
        Group {
            if !isUnlocked && enableAuth {
                content
                    .blur(radius: 15)
                    .overlay {
                        AuthView(isUnlocked: $isUnlocked.animation())
                            .ignoresSafeArea()
                    }
            } else {
                content
            }
        }
    }
}

extension View {
    func authenticationDialog(isUnlocked: Binding<Bool>) -> some View {
        modifier(AuthViewModifier(isUnlocked: isUnlocked))
    }
}
