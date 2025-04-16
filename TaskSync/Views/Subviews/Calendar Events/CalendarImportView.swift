//
//  CalendarImportView.swift
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
        let oneMonthAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        let oneMonthAfter = Date().addingTimeInterval(30 * 24 * 60 * 60)
        let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: calendars)
        
        DispatchQueue.main.async {
            self.events = self.eventStore.events(matching: predicate)
        }
    }
}

struct CalendarImportView: View {
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
                                    Text(event.title)
                                        .font(.headline)
                                    
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
                                
                                Button(action: {
                                    toggleSelection(for: event)
                                }) {
                                    Image(systemName: selectedEvents.contains(event.eventIdentifier) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedEvents.contains(event.eventIdentifier) ? .blue : .gray)
                                        .imageScale(.large)
                                }
                                .buttonStyle(PlainButtonStyle())
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
                        Text("Import")
                            .fontWeight(.bold)
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
            let newTask = Task(
                taskTitle: event.title,
                taskDescription: event.notes ?? "",
                creationDate: event.startDate,
                tint: "taskColor 0",
                priority: .none
            )
            modelContext.insert(newTask)
        }
    }
}

extension Color {
    init(cgColor: CGColor) {
        self.init(UIColor(cgColor: cgColor))
    }
}
