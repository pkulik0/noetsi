//
//  ColorPicker.swift
//  noetsi
//
//  Created by qurrie on 06/06/2022.
//

import SwiftUI

struct ColorPicker: View {
    @Binding var selection: Color
    @Binding var isPresented: Bool

    let items: [Color]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    ForEach(Color.noteColors, id: \.self) { color in
                        Button {
                            selection = color
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Circle()
                                .strokeBorder(.black.opacity(0.5), lineWidth: color == selection ? 5 : 0)
                                .background(Circle().fill(color))
                                .tag(color)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 10)
            .background(Color.secondary.opacity(0.5))
            .clipShape(Capsule())
        }
    }
}

struct NoteColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPicker(selection: .constant(.blue), isPresented: .constant(true), items: [.blue, .red, .green])
    }
}
