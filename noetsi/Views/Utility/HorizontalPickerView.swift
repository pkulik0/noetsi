//
//  HorizontalPickerView.swift
//  noetsi
//
//  Created by pkulik0 on 12/06/2022.
//

import SwiftUI

/// Custom picker which displays the items clipped as circles in a horizontal picker in the shape of a capsule.
struct HorizontalPickerView<ItemType: Hashable, Content: View>: View {

    /// Array of the items to display inside the picker.
    let items: [ItemType]
    
    /// Currently chosen element of ``items``.
    @Binding var selection: ItemType
    
    /// Controls the view's visiblity.
    @Binding var isPresented: Bool
    
    ///
    /// View displayed inside each item's circle.
    /// - Parameter item: The item displayed in this particular circle.
    /// - Returns: The content of the picker's element built using the item.
    ///
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
