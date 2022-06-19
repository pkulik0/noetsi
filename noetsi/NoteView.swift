//
//  NoteView.swift
//  noetsi
//
//  Created by pkulik0 on 30/05/2022.
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
    @State private var showShareView: Bool = false
    @State private var showChecklist: Bool = false
    
    @FocusState private var focusedField: String?

    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        TextField("Title", text: $note.title)
                            .font(.title.bold())
                            .focused($focusedField, equals: "title")
                                  
                        Text(note.body)
                            .foregroundColor(.clear)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height * 0.45)
                            .overlay {
                                TextEditor(text: $note.body)
                                    .focused($focusedField, equals: "body")
                            }
                            .padding(.bottom)
                    }
                    .id("note")
                    .padding([.leading, .top], 25)
                    .background(NoteBackground(color: note.color, pattern: note.pattern))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 5)
                    
                    VStack(alignment: .leading) {
                        if showChangeColor {
                            ThemeEditorView(selection: $note.color, pattern: $note.pattern, isPresented: $showChangeColor)
                                .shadow(radius: 5)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            HStack {
                                TagsView(note: $note, showHeader: true)
                                
                                Spacer()
                                
                                ReminderView(note: $note, showHeader: true)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        if !note.checklist.isEmpty || showChecklist {
                            DropdownView(isShown: $showChecklist) {
                                ChecklistView(checklist: $note.checklist, focusedField: _focusedField)
                            } label: {
                                "Checklist (\(note.checklist.count))"
                            }
                            .padding(.vertical)
                            .id("checklist")
                            .onChange(of: showChecklist) { shown in
                                withAnimation {
                                    reader.scrollTo(shown ? "checklist" : "note")
                                }
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .ignoresSafeArea(.keyboard, edges: showChecklist ? Edge.Set() : .all)
                }
                .padding()
            }
        }
        .alert("Are you sure?", isPresented: $showDeleteAlert, actions: {
            Button("Delete", role: .destructive, action: deleteNote)
            Button("Cancel", role: .cancel) {}
        })
        .sheet(isPresented: $showTagEditor, content: {
            TagEditorView(tags: $note.tags)
        })
        .toolbar {
            toolbarItems
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareView, content: {
            ShareItemsView(activityItems: [note.shareable], applicationActivites: nil)
        })
        .onAppear {
            noteCopy = note.copy()
            UITextView.appearance().backgroundColor = .clear
        }
        .onDisappear {
            if note.isEmpty {
                note.deleteMe = true
            } else if note != noteCopy {
                firestoreManager.writeNote(note: note)
            }
        }
        .onChange(of: focusedField) { newValue in
            print("filde \(newValue ?? "err")")
        }
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !showChecklist && note.checklist.isEmpty {
                    Button {
                        withAnimation {
                            showChecklist.toggle()
                        }
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "plus")
                                .font(.caption2)
                            Image(systemName: "checklist")
                        }
                    }
                }
                Button {
                    withAnimation {
                        showChangeColor.toggle()
                    }
                } label: {
                    Label("Change color", systemImage: showChangeColor ? "paintpalette.fill" : "paintpalette")
                }
                Button {
                    showShareView = true
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
                    focusedField = nil
                }
            }
        }
    }
    
    func deleteNote() {
        note.deleteMe = true
        dismiss()
    }
}
