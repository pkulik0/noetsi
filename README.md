## Description

Noetsi is a cloud synchronized notes app with support for various backgrounds and attachments.

## Stack

- Swift
- SwiftUI
- XCTest
- LocalAuthentication
- UserNotifications
- Firestore Authentication
- Firestore Cloud Database (NoSQL)
- XCode DocC

## Screenshots

Main View

<img style="height:500px;width:auto;" src="https://i.imgur.com/KFZ8BKb.png">

Note Details

<img style="height:500px;width:auto;" src="https://i.imgur.com/YYUxu2d.png">

Note Theme Picker

<img style="height:500px;width:auto;" src="https://i.imgur.com/Ugbt8mu.png">

Note Checklist

<img style="height:500px;width:auto;" src="https://i.imgur.com/AYtqP52.png">

Tag Editor

<img style="height:500px;width:auto;" src="https://i.imgur.com/hAj6sNW.png">

Reminder Editor

<img style="height:500px;width:auto;" src="https://i.imgur.com/hgEYKkz.png">

Tags View

<img style="height:500px;width:auto;" src="https://i.imgur.com/TfDfMrl.png">

Settings

<img style="height:500px;width:auto;" src="https://i.imgur.com/UgPZi7f.png">

Login Screen

<img style="height:500px;width:auto;" src="https://i.imgur.com/HudyqlZ.png">

## Code organization

### Data controllers
- FirestoreManager

### Data classes/structs
- Note
- Pattern
- ChecklistEntry

### Entry point
- noetsiApp

### Root views
- WelcomeView
- MainView

### Tabs
- NotesView
- TagsView
- SettingsView

### Note views
- NoteView
- NoteListRowView
- NoteBackground
- ThemeEditorView

### Checklist views
- CheckboxView
- ChecklistView

### Reminder views
- ReminderView
- ReminderFormView

### Tag views
- TagView
- TagRollView
- TagListRowView
- TagEditorView

### Authentication views

- LocalAuthView
- LocalAuthViewModifier

### Utility
- HorizontalPickerView
- DropdownView
- DragToHide
- ShareItemsView
