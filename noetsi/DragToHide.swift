//
//  DragToHide.swift
//  noetsi
//
//  Created by pkulik0 on 16/06/2022.
//

import SwiftUI

struct DragToHide: ViewModifier {
    @Binding var offset: CGSize
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .onChanged({ value in
                    let amountVertical = value.translation.height
                    if amountVertical > 0 {
                        withAnimation {
                            offset.height = amountVertical
                        }
                    }
                })
                .onEnded({ value in
                    withAnimation {
                        if value.translation.height > 40 {
                            isPresented = false
                        }
                        offset = CGSize.zero
                    }
                })
            )
    }
}

extension View {
    func hideOnDrag(offset: Binding<CGSize>, isPresented: Binding<Bool>) -> some View {
        modifier(DragToHide(offset: offset, isPresented: isPresented))
    }
}
