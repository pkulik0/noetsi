//
//  ReminderFormView.swift
//  noetsi
//
//  Created by qurrie on 16/06/2022.
//

import SwiftUI

struct ReminderFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date = Date()
    @State private var repeating: Bool = false
    
    @State private var includeDate: Bool = false
    @State private var includeTime: Bool = true

    let id: String
    let title: String
    let subtitle: String
    @Binding var request: UNNotificationRequest?
    
    private var isSaveDisabled: Bool {
        !includeDate && !includeTime
    }

    var body: some View {
        NavigationView {
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
                    Button("Save") {
                        addNotification()
                    }
                    .disabled(isSaveDisabled)
                }
            }
            .navigationTitle("Reminder details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if request != nil {
                        Button("Delete", role: .destructive) {
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                            request = nil
                            dismiss()
                        }
                        .tint(.red)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            retrieveData()
        }
    }
    
    func retrieveData() {
        guard let request = request else {
            return
        }
        
        guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
            return
        }
        
        repeating = trigger.repeats
        date = Calendar.current.date(from: trigger.dateComponents) ?? Date()
        
        includeDate = trigger.dateComponents.day != nil
        includeTime = trigger.dateComponents.hour != nil
    }
    
    func addNotification() {
        let notifCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
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
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        let runOnSuccess = {
            notifCenter.add(request)
            self.request = request
            dismiss()
        }
        
        notifCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                runOnSuccess()
            } else {
                notifCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if let error = error {
                        print("Error during notification authorization: \(error.localizedDescription)")
                        return
                    }
                    if granted {
                        runOnSuccess()
                    }
                }
            }
        }
    }
}
