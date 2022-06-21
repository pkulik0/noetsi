//
//  NoteChecklistView.swift
//  noetsi
//
//  Created by pkulik0 on 19/06/2022.
//

import SwiftUI

/// Container with a chevron next to its label which expands on tap.
struct DropdownView<Content: View>: View {
    /// Controls the visibility of the content.
    @Binding var isShown: Bool
    
    /// View to be shown when expanded.
    var content: () -> Content

    /// Text displayed next to a chevron at the top of the view.
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
