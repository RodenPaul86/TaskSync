//
//  calendarImportView.swift
//  TaskSync
//
//  Created by Paul  on 4/16/25.
//

import SwiftUI
import EventKit
import SwiftData

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var events: [EKEvent] = []
    
    func requestAccess() {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                if granted {
                    self.fetchEvents()
                } else {
                    print("Access denied or error: \(String(describing: error))")
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    self.fetchEvents()
                } else {
                    print("Access denied or error: \(String(describing: error))")
                }
            }
        }
    }
    
    func fetchEvents() {
        let calendars = eventStore.calendars(for: .event)
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let endOfYear = Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: Date()),
            month: 12,
            day: 31
        )) ?? Date().addingTimeInterval(60 * 60 * 24 * 180)
        
        let predicate = eventStore.predicateForEvents(withStart: startOfToday, end: endOfYear, calendars: calendars)
        
        DispatchQueue.main.async {
            self.events = self.eventStore.events(matching: predicate)
        }
    }
}

struct calendarImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var calendarManager = CalendarManager()
    
    @State private var selectedEvents: Set<String> = []
    
    var body: some View {
        NavigationStack {
            let now = Date()
            let upcomingEvents = calendarManager.events
                .filter { $0.endDate >= now }
                .sorted { $0.startDate < $1.startDate }
            
            // Group events by month
            let groupedEvents = Dictionary(grouping: upcomingEvents) { event in
                let components = Calendar.current.dateComponents([.year, .month], from: event.startDate)
                return Calendar.current.date(from: components) ?? Date()
            }
            
            List {
                ForEach(groupedEvents.keys.sorted(), id: \.self) { monthDate in
                    Section(header: Text(monthDate.formatted(.dateTime.year().month(.wide)))) {
                        ForEach(groupedEvents[monthDate] ?? [], id: \.eventIdentifier) { event in
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(event.title)
                                            .font(.headline)
                                        
                                        if let rules = event.recurrenceRules, !rules.isEmpty {
                                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Text(event.startDate, style: .date)
                                        Text(event.startDate, style: .time)
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(cgColor: event.calendar.cgColor ?? UIColor.systemGray.cgColor))
                                            .frame(width: 8, height: 8)
                                        Text(event.calendar.title)
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        if selectedEvents.contains(event.eventIdentifier) {
                                            selectedEvents.remove(event.eventIdentifier)
                                        } else {
                                            selectedEvents.insert(event.eventIdentifier)
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .stroke(selectedEvents.contains(event.eventIdentifier) ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 28, height: 28)
                                            .overlay {
                                                if selectedEvents.contains(event.eventIdentifier) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundStyle(.blue.gradient)
                                                        .frame(width: 16, height: 16)
                                                        .transition(.scale)
                                                }
                                            }
                                    }
                                    .contentShape(Circle()) // for larger tap target
                                }
                                .buttonStyle(.plain)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleSelection(for: event)
                            }
                        }
                    }
                }
            }
            .onAppear {
                calendarManager.requestAccess()
                NotificationManager.shared.requestAuthorization()
            }
            .navigationTitle("Import Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        importSelectedEvents(events: upcomingEvents)
                        dismiss()
                    }) {
                        if selectedEvents.isEmpty {
                            Text("Import")
                                .fontWeight(.medium)
                        } else {
                            Text("Import (\(selectedEvents.count))")
                                .fontWeight(.medium)
                        }
                    }
                    .disabled(selectedEvents.isEmpty)
                }
            }
        }
    }
    
    private func toggleSelection(for event: EKEvent) {
        if selectedEvents.contains(event.eventIdentifier) {
            selectedEvents.remove(event.eventIdentifier)
        } else {
            selectedEvents.insert(event.eventIdentifier)
        }
    }
    
    private func importSelectedEvents(events: [EKEvent]) {
        let eventsToImport = events.filter { selectedEvents.contains($0.eventIdentifier) }
        for event in eventsToImport {
            let newTask = TaskData(
                taskTitle: event.title,
                taskDescription: event.notes ?? "",
                creationDate: event.startDate,
                tint: "taskColor 0",
                priority: .basic
            )
            modelContext.insert(newTask)
            NotificationManager.shared.scheduleNotification(for: newTask)
        }
    }
}

extension Color {
    init(cgColor: CGColor) {
        self.init(UIColor(cgColor: cgColor))
    }
}
