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
                            UISelectionFeedbackGenerator().selectionChanged()
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
