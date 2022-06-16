//
//  NotificationView.swift
//  noetsi
//
//  Created by qurrie on 16/06/2022.
//

import SwiftUI
import UserNotifications

struct ReminderView: View {
    @Binding var note: Note
    let showHeader: Bool
    
    let center = UNUserNotificationCenter.current()
    @State var request: UNNotificationRequest?
    
    @State private var showCreator: Bool = false
    
    private var trigger: UNCalendarNotificationTrigger {
        guard let request = self.request else {
            return UNCalendarNotificationTrigger(dateMatching: DateComponents(), repeats: false)
        }
        
        guard let trigger = request.trigger else {
            return UNCalendarNotificationTrigger(dateMatching: DateComponents(), repeats: false)
        }
        
        return trigger as? UNCalendarNotificationTrigger ?? UNCalendarNotificationTrigger(dateMatching: DateComponents(), repeats: false)
    }
    
    private var date: String {
        let dateComponents = trigger.dateComponents
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = dateComponents.minute != nil ? .short : .none
        dateFormatter.dateStyle = dateComponents.day != nil ? .short : .none
        
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if showHeader {
                Text("Reminder:")
                    .font(.headline)
            }
            HStack {
                if let _ = request {
                    HStack(spacing: 0) {
                        if trigger.repeats {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Text(date)
                    }
                    .font(.caption)
                    .padding(10)
                    .background(Capsule().strokeBorder(note.color, lineWidth: 3).opacity(0.75))
                       
                }
                
                Button {
                    showCreator = true
                } label: {
                    Image(systemName: request != nil ? "bell.fill" : "plus")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(note.color.opacity(0.75))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .onAppear {
                getNotification()
            }
        }
        .sheet(isPresented: $showCreator) {
            ReminderCreatorView(note: note, request: $request)
        }
    }
    
    func getNotification() {
        center.getPendingNotificationRequests { requests in
            for request in requests {
                if request.identifier == note.id {
                    self.request = request
                    break
                }
            }
        }
    }
}
