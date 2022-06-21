//
//  NotificationView.swift
//  noetsi
//
//  Created by pkulik0 on 16/06/2022.
//

import SwiftUI

///
/// Shows a ``Note``'s reminder if it has one.
///
/// ``ReminderView`` shows enables users to initiate adding a new reminder and displays the information about the current one if it exists.
///
struct ReminderView: View {
    
    /// Currently displayed ``Note``.
    @Binding var note: Note
    
    /// Enables a version of the view that only displays *existing* reminders without a header or a button.
    let compact: Bool
    
    /// Controls the visiblity of ``ReminderFormView``
    @State private var showAddReminder = false
    
    /// Wrapper around the ``Note``'s notification request trigger which casts it to a Calendar trigger.
    private var trigger: UNCalendarNotificationTrigger {
        guard let request = self.note.reminder else {
            return UNCalendarNotificationTrigger(dateMatching: DateComponents(), repeats: false)
        }
        
        return request.trigger as? UNCalendarNotificationTrigger ?? UNCalendarNotificationTrigger(dateMatching: DateComponents(), repeats: false)
    }
    
    /// Converts the trigger's dateComponents to a string.
    private var dateString: String {
        let dateComponents = trigger.dateComponents
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = dateComponents.minute != nil ? .short : .none
        dateFormatter.dateStyle = dateComponents.day != nil ? .short : .none
        
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !compact {
                Text("Reminder:")
                    .font(.headline)
            }
            HStack {
                if let _ = note.reminder {
                    HStack(spacing: 0) {
                        if trigger.repeats {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Text(dateString)
                    }
                    .font(.caption)
                    .padding(10)
                    .background(Capsule().strokeBorder(note.color, lineWidth: 3).opacity(0.75))
                       
                }
                
                if !compact {
                    Button {
                        showAddReminder = true
                    } label: {
                        Image(systemName: note.reminder != nil ? "pencil" : "plus")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(note.color.opacity(0.75))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showAddReminder) {
            ReminderFormView(id: note.id, title: note.title, subtitle: note.bodyInline, request: $note.reminder)
        }
    }
}
