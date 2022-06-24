//
//  NoteView.swift
//  noetsi
//
//  Created by pkulik0 on 30/05/2022.
//

import SwiftUI

/// ``NoteView`` presents all the available information about a ``Note`` to the user and enables modification.
struct NoteView: View {

    /// This view's main source of data.
    @Binding var note: Note
    
    /// The displayed ``Note``'s copy used to detect changes.
    @State private var noteCopy = Note()
    
    /// Keeps track of the focused field to dismiss the keyboard after the user presses *Done* on the toolbar.
    @FocusState private var focusedField: String?

    /// Value responsible for showing a warning to the user before queuing ``note`` for deletion.
    @State private var showDeleteAlert: Bool = false
    
    /// Controls the visibility of ``ThemeEditorView``.
    @State private var showThemeEditor: Bool = false
    
    /// Controls the visiblity of a sheet with ``TagEditorView``.
    @State private var showTagEditor: Bool = false
    
    /// Show a view allowing the user to share the note. (``ShareItemsView``)
    @State private var showShareView: Bool = false
    
    /// Toggle the visibility of the checklist section.
    @State private var showChecklist: Bool = false
    
    /// Returns true if either there are checklist elements or the user has specifically requested to show the checklist.
    private var showDropdown: Bool {
        !note.checklist.isEmpty || showChecklist
    }
    
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        TextField("Title", text: $note.title)
                            .font(.title.bold())
                            .focused($focusedField, equals: "title")
                                
                        noteEditor
                    }
                    .id("note")
                    .padding([.leading, .top], 25)
                    .background(NoteBackground(color: note.color, pattern: note.pattern))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 5)
                    
                    VStack(alignment: .leading) {
                        if showThemeEditor {
                            ThemeEditorView(selection: $note.color, pattern: $note.pattern, isPresented: $showThemeEditor)
                                .shadow(radius: 5)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            HStack {
                                TagRollView(note: $note, compact: false)
                                
                                Spacer()
                                
                                ReminderView(note: $note, compact: false)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        if showDropdown {
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
        .toolbar {
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
                        showThemeEditor.toggle()
                    }
                } label: {
                    Label("Change color", systemImage: showThemeEditor ? "paintpalette.fill" : "paintpalette")
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
    
    /// SwiftUI TextEditor wrapped around with other views to add a placeholder and fix its size issue.
    var noteEditor: some View {
        ZStack(alignment: .topLeading) {
            if note.body.isEmpty {
                Text("Empty")
                    .opacity(0.5)
                    .padding(.top, 10)
                    .padding(.leading, 5)
            }
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
    }
    
    /// Queue ``note`` for deletion.
    func deleteNote() {
        note.deleteMe = true
        dismiss()
    }
}
