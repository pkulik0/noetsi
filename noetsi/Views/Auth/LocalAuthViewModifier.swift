//
//  LocalAuthViewModifier.swift
//  noetsi
//
//  Created by pkulik0 on 17/06/2022.
//

import SwiftUI

struct LocalAuthViewModifier: ViewModifier {
    @AppStorage("enableAuth") private var enableAuth = false
    @Binding var isUnlocked: Bool

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
    func localAuthenticationDialog(isUnlocked: Binding<Bool>) -> some View {
        modifier(LocalAuthViewModifier(isUnlocked: isUnlocked))
    }
}
