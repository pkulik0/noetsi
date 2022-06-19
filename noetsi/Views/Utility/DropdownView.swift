//
//  NoteChecklistView.swift
//  noetsi
//
//  Created by pkulik0 on 19/06/2022.
//

import SwiftUI

struct DropdownView<Content: View>: View {
    @Binding var isShown: Bool
    var content: () -> Content
    var label: () -> String

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation {
                    isShown.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: isShown ? "chevron.down" : "chevron.right")
                    
                    Text(label())
                        .font(.headline)
                }
            }
            .buttonStyle(.plain)
            
            if isShown {
                content()
                    .padding(.leading, 25)
            }
        }
    }
}
