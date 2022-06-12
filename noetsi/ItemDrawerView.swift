//
//  ItemDrawerView.swift
//  noetsi
//
//  Created by qurrie on 12/06/2022.
//

import SwiftUI

struct ItemDrawerView: View {
    @Binding var isPresented: Bool

    @State private var offset: CGSize = CGSize.zero
    @State private var selection = ""
    let items = ["checklist", "photo", "map"]
    
    var body: some View {
        VStack {
            HorizontalPickerView(items: items, selection: $selection, isPresented: $isPresented) { item in
                ZStack {
                    Color(uiColor: UIColor.systemBackground)
                        .opacity(0.8)
                    
                    Image(systemName: item)
                        .font(.title.bold())
                }
            }
            .hideOnDrag(offset: $offset, isPresented: $isPresented)
        }
        .onChange(of: selection) { item in
            switch(item) {
            case "checklist":
                addChecklist()
            case "photo":
                addImage()
            case "map":
                addLocation()
            default:
                break
            }
        }
    }
    
    func addChecklist() {
        print("checklist")
    }
    func addImage() {
        print("image")
    }
    func addLocation() {
        print("location")
    }
}
