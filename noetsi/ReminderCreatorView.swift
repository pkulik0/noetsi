//
//  ReminderCreatorView.swift
//  noetsi
//
//  Created by qurrie on 16/06/2022.
//

import SwiftUI

struct ReminderCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date = Date()
    @State private var repeating: Bool = false
    
    @State private var includeDate: Bool = false
    @State private var includeTime: Bool = true

    @ObservedObject var note: Note
    @Binding var request: UNNotificationRequest?
    
    let center = UNUserNotificationCenter.current()
    
    var isDisabled: Bool {
        !includeDate && !includeTime
    }

    var body: some View {
        Form {
            Section {
                Toggle("Time", isOn: $includeTime.animation())
                    .toggleStyle(.switch)
                if includeTime {
                    DatePicker("Reminder time", selection: $date, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.graphical)
                }
            }
            Section {
                Toggle("Date", isOn: $includeDate.animation())
                    .toggleStyle(.switch)
                if includeDate {
                    DatePicker("Reminder date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
            }
            Section {
                Toggle("Repeating", isOn: $repeating.animation())
                    .toggleStyle(.switch)
            }
            Section {
                Button("Create reminder") {
                    addNotification()
                }
                .disabled(isDisabled)
            }
        }
    }
    
    func addNotification() {
        let content = UNMutableNotificationContent()
        content.title = note.title
        content.subtitle = note.bodyCompact.replacingOccurrences(of: "\n", with: " ")
        content.sound = .default
        
        var components: Set<Calendar.Component> = []
        if includeDate {
            components = components.union([.day, .month, .year])
        }
        if includeTime {
            components = components.union([.hour, .minute])
        }
        let dateComponents = Calendar.current.dateComponents(components, from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeating)
        
        self.request = UNNotificationRequest(identifier: note.id, content: content, trigger: trigger)
        
        guard let request = request else {
            return
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest(request)
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest(request)
                    } else {
                        print("Notifications denied")
                    }
                }
            }
        }
    }
    
    func addRequest(_ request: UNNotificationRequest) {
        center.add(request)
        dismiss()
    }
}
