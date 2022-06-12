//
//  HorizontalPickerView.swift
//  noetsi
//
//  Created by qurrie on 12/06/2022.
//

import SwiftUI

struct HorizontalPickerView<ItemType: Hashable, Content: View>: View {
    let items: [ItemType]
    @Binding var selection: ItemType
    @Binding var isPresented: Bool
    let content: (_ item: ItemType) -> Content
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Spacer()
                ForEach(items, id: \.self) { item in
                    Button {
                        withAnimation {
                            selection = item
                            isPresented = false
                        }
                    } label: {
                        ZStack {
                            content(item)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
                            if item == selection {
                                Image(systemName: "checkmark")
                                    .font(.title2.bold())
                                    .opacity(0.5)
                            }
                        }
                        .tag(item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.3))
        .clipShape(Capsule())
    }
}

extension View {
    func hideOnDrag(offset: Binding<CGSize>, isPresented: Binding<Bool>) -> some View {
        modifier(DragToHide(offset: offset, isPresented: isPresented))
    }
}

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
