//
//  ColorPicker.swift
//  noetsi
//
//  Created by pkulik0 on 06/06/2022.
//

import SwiftUI

/// Contains a ``Note`` pattern editor and a background color picker.
struct ThemeEditorView: View {
    
    /// Currently selected background color.
    @Binding var selection: Color
    
    /// The ``Note``'s background pattern.
    @Binding var pattern: Note.Pattern
    
    /// Controls the view's visibility.
    @Binding var isPresented: Bool
    
    /// Pattern size picker is shown only if pattern is not set to none.
    @State private var showSizePicker: Bool
    
    /// The view's offset used for the ``DragToHide`` modifier.
    @State private var offset: CGSize
    
    init(selection: Binding<Color>, pattern: Binding<Note.Pattern>, isPresented: Binding<Bool>) {
        _selection = selection
        _pattern = pattern
        _isPresented = isPresented
        _showSizePicker = State(initialValue: pattern.type.wrappedValue != .None)
        _offset = State(initialValue: CGSize.zero)
    }

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Pattern")
                        .font(.caption)
                    
                    Picker("Size", selection: $pattern.type) {
                        Label("None", systemImage: "square.slash")
                            .tag(Note.PatternType.None)
                        Label("Lines", systemImage: "line.3.horizontal")
                            .tag(Note.PatternType.Lines)
                        Label("Grid", systemImage: "grid")
                            .tag(Note.PatternType.Grid)
                    }
                    .labelStyle(.iconOnly)
                    .pickerStyle(.segmented)
                    .onChange(of: pattern.type) { newType in
                        withAnimation {
                            showSizePicker = newType != .None
                        }
                    }
                }
                
                if showSizePicker {
                    VStack {
                        Text("Size")
                            .font(.caption)
                        
                        Picker("Size", selection: $pattern.size) {
                            Text("S").tag(15.0)
                            Text("M").tag(20.0)
                            Text("L").tag(30.0)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            
            HorizontalPickerView(items: Color.noteColors, selection: $selection, isPresented: $isPresented) { item in
                item
            }
        }
        .hideOnDrag(offset: $offset, isPresented: $isPresented)
    }
}
