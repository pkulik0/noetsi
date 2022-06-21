# ``noetsi``

Version 1.0 by pkulik0

## Description

Noetsi is a cloud synchronized notes app with support for various backgrounds and attachments.

## Technology

- Swift
- SwiftUI
- XCTest
- LocalAuthentication
- UserNotifications
- Firestore Authentication
- Firestore Cloud Database (NoSQL)
- XCode DocC (Documentation Compiler)

## Topics

### Data controllers
- ``FirestoreManager``

### Data classes/structs
- ``Note``
- ``Pattern``
- ``ChecklistItem``

### Entry point
- ``noetsiApp``

### Root views
- ``WelcomeView``
- ``MainView``

### Tabs
- ``NotesView``
- ``TagsView``
- ``SettingsView``

### Note views
- ``NoteView``
- ``NoteListRowView``
- ``NoteBackground``
- ``ThemeEditorView``
- ``ReminderView``
- ``ReminderFormView``
- ``CheckboxView``
- ``ChecklistView``

### Tag views
- ``TagView``
- ``TagRollView``
- ``TagListRowView``
- ``TagEditorView``

### Authentication views

- ``LocalAuthView``
- ``LocalAuthViewModifier``

### Utility
- ``HorizontalPickerView``
- ``DropdownView``
- ``DragToHide``
- ``ShareItemsView``
