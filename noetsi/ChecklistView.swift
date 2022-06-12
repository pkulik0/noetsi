//
//  ChecklistView.swift
//  noetsi
//
//  Created by qurrie on 12/06/2022.
//

import SwiftUI

struct ChecklistView: View {
    @Binding var checklist: [Note.ChecklistItem]
    
    @State private var newItem: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array($checklist.enumerated()), id: \.offset) { index, item in
                HStack {
                    Checkbox(isOn: item.isChecked)
                    
                    TextField("Item", text: item.text)
                        .font(.subheadline)
                        .fixedSize()
                    
                    Image(systemName: "xmark")
                        .font(.caption)
                        .padding(.horizontal, 1)
                        .onTapGesture {
                            checklist.remove(at: index)
                        }
                }
                .padding(.bottom, 5)
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
                    .font(.subheadline)
                    .fixedSize()
                    .onSubmit {
                        addItem()
                    }
            }
            .padding(.bottom)
        }
    }
    
    func addItem() {
        if !newItem.isEmpty && newItem.trimmingCharacters(in: .whitespaces).rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
            checklist.append(Note.ChecklistItem(text: newItem, isChecked: false))
            newItem = ""
        }
    }
}

struct Checkbox: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            withAnimation {
                isOn.toggle()
            }
        } label: {
            ZStack {
                if isOn {
                    Image(systemName: "checkmark")
                        .foregroundColor(.primary)
                        .font(.caption)
                }
                
                isOn ? Color.secondary : Color.clear
            }
            .frame(width: 25, height: 25)
            .clipShape(Circle())
            .background(Circle().strokeBorder(Color.secondary, lineWidth: 3))
        }
        .buttonStyle(.plain)
    }
}
