//
//  NoteView.swift
//  noetsi
//
//  Created by qurrie on 30/05/2022.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) private var dismiss
    
    @Binding var note: Note

    @State private var noteCopy = Note()

    @State private var showDeleteAlert: Bool = false
    @State private var showChangeColor: Bool = false
    @State private var showTagEditor: Bool = false
    
    @FocusState private var isBodyFocused: Bool
    @FocusState private var isTitleFocused: Bool
    
    private var patternSize: Int {
        Int(note.pattern.size)
    }

    var body: some View {
        VStack {
            ZStack {
                note.color.opacity(0.4)
                
                if note.pattern.type != .None {
                    GeometryReader { geo in
                        if note.pattern.type == .Grid {
                            ForEach(0..<(Int(Int(geo.size.width) / patternSize) + 1), id: \.self) { i in
                                Path { path in
                                    let x = i * patternSize
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x, y: Int(geo.size.height)))
                                    path.closeSubpath()
                                }
                                .stroke(note.color.opacity(0.25), lineWidth: 2)
                            }
                        }
                        
                        ForEach(0..<Int(Int(geo.size.height) / patternSize), id: \.self) { i in
                            Path { path in
                                let y = i * patternSize
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: Int(geo.size.width), y: y))
                                path.closeSubpath()
                            }
                            .stroke(note.color.opacity(0.25), lineWidth: 2)
                        }
                    }
                    .drawingGroup()
                    .ignoresSafeArea(.all, edges: .bottom)
                }
                
                VStack(alignment: .leading) {
                    TextField("Title", text: $note.title)
                        .font(.title.bold())
                        .focused($isTitleFocused)
                                        
                    ZStack(alignment: .topLeading) {
                        if note.body.isEmpty {
                            Text("Empty")
                                .opacity(0.5)
                                .padding(.top, 10)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $note.body)
                            .focused($isBodyFocused)
                            .onAppear {
                                UITextView.appearance().backgroundColor = .clear
                            }
                    }
                }
                .padding([.top, .leading], 25)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
            
            TagListView(note: $note, showHeader: true)
                .padding(.top)
            
            if showChangeColor {
                ColorPicker(selection: $note.color, pattern: $note.pattern, isPresented: $showChangeColor)
                    .shadow(radius: 5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .alert("Are you sure?", isPresented: $showDeleteAlert, actions: {
            Button("Delete", role: .destructive, action: deleteNote)
            Button("Cancel", role: .cancel) {}
        })
        .sheet(isPresented: $showTagEditor, content: {
            TagEditorView(tags: $note.tags)
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    // add smth
                } label: {
                    Label("Add", systemImage: "plus")
                }
                Button {
                    withAnimation {
                        showChangeColor.toggle()
                    }
                } label: {
                    Label("Change color", systemImage: "paintpalette")
                }
                Button {
                    // share a copy
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    isBodyFocused = false
                    isTitleFocused = false
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            noteCopy = note.copy()
        }
        .onDisappear {
            if note.isEmpty {
                note.deleteMe = true
            } else if note != noteCopy {
                firestoreManager.writeNote(note: note)
            }
        }
    }
    
    func deleteNote() {
        note.deleteMe = true
        dismiss()
    }
}
