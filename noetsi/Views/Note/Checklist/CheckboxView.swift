//
//  CheckboxView.swift
//  noetsi
//
//  Created by pkulik0 on 19/06/2022.
//

import SwiftUI

struct CheckboxView: View {
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
            .background(Circle().strokeBorder(Color.secondary, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}
