//
//  ReminderFormView.swift
//  noetsi
//
//  Created by pkulik0 on 16/06/2022.
//

import SwiftUI

/// Form used to create a new ``Note`` reminder.
struct ReminderFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date = Date()
    @State private var repeating: Bool = false
    
    @State private var includeDate: Bool = false
    @State private var includeTime: Bool = true

    ///
    /// The notification's identifier.
    ///
    /// Noetsi uses the id of a ``Note`` as the ``id`` of its notification to keep only one notification for every ``Note``.
    ///
    let id: String
    
    /// The text to display as the title of the notification.
    let title: String
    
    /// The notifications content.
    let subtitle: String
    @Binding var request: UNNotificationRequest?
    
    /// Used to block saving reminders if there is not enough data to create a trigger.
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
    
    /// Retrieve data from an existing notification request and display it in the view.
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
    
    /// Create a new notification with the view's data.
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
            DispatchQueue.main.async {
                self.request = request
            }
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
