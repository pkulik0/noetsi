//
//  LocalAuthViewModifier.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

/// Covers the underlying view and displays ``LocalAuthView`` over it.
struct LocalAuthViewModifier: ViewModifier {
    
    /// Keeps track of the user's authentication status.
    @Binding var isUnlocked: Bool
    
    /// Read the user's local authentication preferences (*disabled* by default)
    @AppStorage("enableAuth") private var enableAuth = false

    func body(content: Content) -> some View {
        Group {
            if !isUnlocked && enableAuth {
                content
                    .blur(radius: 15)
                    .overlay {
                        LocalAuthView(isUnlocked: $isUnlocked.animation())
                            .ignoresSafeArea()
                    }
            } else {
                content
            }
        }
    }
}

extension View {
    /// Apply ``LocalAuthViewModifier`` to the view.
    func localAuthenticationDialog(isUnlocked: Binding<Bool>) -> some View {
        modifier(LocalAuthViewModifier(isUnlocked: isUnlocked))
    }
}
