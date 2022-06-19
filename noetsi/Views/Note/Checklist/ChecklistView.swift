//
//  ChecklistView.swift
//  noetsi
//
//  Created by pkulik0 on 12/06/2022.
//

import SwiftUI

struct ChecklistView: View {
    @Binding var checklist: [Note.ChecklistItem]
    
    @State private var newItem: String = ""
    @FocusState var focusedField: String?

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array($checklist.enumerated()), id: \.offset) { index, item in
                HStack {
                    CheckboxView(isOn: item.isChecked)
                    
                    Text(item.text.wrappedValue)
                        .font(.body)
                        .strikethrough(item.isChecked.wrappedValue, color: .primary)
                    
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 2)
                        .onTapGesture {
                            checklist.remove(at: index)
                        }
                }
            }
            .animation(.default, value: checklist)
        }
        HStack {
            Button(action: addItem) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .background(Color.secondary)
                    .clipShape(Circle())
            }
            TextField("Add Item", text: $newItem)
                .font(.headline)
                .focused($focusedField, equals: "addItem")
                .onSubmit {
                    addItem()
                }
        }
        .padding(.top, 5)
    }
    
    func addItem() {
        if !newItem.trimmingCharacters(in: .whitespaces).isEmpty {
            checklist.append(Note.ChecklistItem(text: newItem, isChecked: false))
            newItem = ""
        }
    }
}


