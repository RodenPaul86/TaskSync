//
//  Home.swift
//  TaskSync
//
//  Created by Paul  on 3/30/25.
//

import SwiftUI
import SwiftData
import StoreKit

struct HomeView: View {
    // MARK: Paywall Properties
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @Environment(\.requestReview) var requestReview
    @State private var isPaywallPresented: Bool = false
    @State private var hasCheckedSubscription = false
    
    // Appearance Properties
    @AppStorage("AppScheme") private var appScheme: AppScheme = .device
    @SceneStorage("ShowScenePickerView") private var showPickerView: Bool = false
    
    // MARK: Properties
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var createTask: Bool = false
    @State private var showInfo: Bool = false
    @State private var showSettings: Bool = false
    @State private var showCalendarImport = false
    @Namespace private var animation
    
    @Query var tasks: [TaskData] /// <-- Ensure this fetches all tasks
    
    var tasksForSelectedDate: [TaskData] {
        tasks.filter {
            Calendar.current.isDate($0.creationDate, inSameDayAs: currentDate) &&
            !$0.isCompleted &&
            !$0.creationDate.isPast // Only tasks that are incomplete and not expired
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    TasksView(currentDate: $currentDate) /// <-- View of tasks
                }
                .hSpacing(.center)
                .vSpacing(.center)
            }
        }
        .vSpacing(.top)
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                createTask.toggle()
            }) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.blue.gradient.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: Circle())
            }
            .padding(15)
        }
        .onAppear {
            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()
                
                if let firstDate = currentWeek.first?.date {
                    weekSlider.append(firstDate.currentPreviousWeek())
                }
                
                weekSlider.append(currentWeek)
                
                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.currentNextWeek())
                }
            }
            
            if !hasCheckedSubscription {
                checkSubscription()
            }
        }
        .sheet(isPresented: $createTask, onDismiss: {
            if AppReviewRequest.requestAvailable {
                Task {
                    try await Task.sleep(
                        until: .now + .seconds(1),
                        tolerance: .seconds(0.5),
                        clock: .suspending
                    )
                    requestReview()
                }
            }
        }) {
            NewTaskView(defaultDate: currentDate)
                .presentationDetents([.height(400)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
        }
        .fullScreenCover(isPresented: $isPaywallPresented) {
            SubscriptionView(isPaywallPresented: $isPaywallPresented)
                .preferredColorScheme(.dark)
        }
        .animation(.easeInOut, value: appScheme)
    }
    
    // MARK: Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Button(action: {
                    let today = Date()
                    
                    if let todayIndex = indexOfCurrentWeek() {
                        withAnimation {
                            currentDate = today
                            currentWeekIndex = todayIndex
                        }
                    } else {
                        let todayWeek = generateWeek(for: today)
                        weekSlider.insert(todayWeek, at: 0)
                        
                        withAnimation {
                            currentDate = today
                            currentWeekIndex = 0
                        }
                    }
                }) {
                    Text(currentDate.format("MMMM"))
                }
                
                Text(currentDate.format("YYYY"))
                    .foregroundStyle(.gray)
            }
            .font(.title.bold())
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
            
            let incompleteTasks = tasksForSelectedDate
            let expiredTasks = tasks.filter {
                Calendar.current.isDate($0.creationDate, inSameDayAs: currentDate) &&
                !$0.isCompleted &&
                $0.creationDate.isPast
            }
            
            if !incompleteTasks.isEmpty {
                Text("\(incompleteTasks.count) task\(incompleteTasks.count > 1 ? "s" : "") are still alive and well. Unlike your motivation.")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            
            // Display expired tasks
            if !expiredTasks.isEmpty {
                Text("\(expiredTasks.count) task\(expiredTasks.count > 1 ? "s" : "") are overdue. Don’t worry, we told no one… yet.")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }
            
            if incompleteTasks.isEmpty && expiredTasks.isEmpty {
                Text("No tasks. No chaos. No fun.")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
            
            /// Week Slider
            TabView(selection: $currentWeekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    weekView(week)
                        .padding(.horizontal, 15)
                        .tag(index)
                }
            }
            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .overlay(alignment: .topTrailing) {
            HStack {
                Button(action: { showPickerView.toggle() }) {
                    Image(systemName: appScheme == .dark ? "sun.max.circle" : "moon.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .clipShape(.circle)
                }
                
                Menu {
                    Button(action: { showCalendarImport.toggle() }) {
                        Label("Import from Calender", systemImage: "square.and.arrow.down.badge.clock")
                    }
                    .disabled(appSubModel.isSubscriptionActive ? false : true)
                    
                    Button(action: { showSettings.toggle() }) {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    Button(action: { showInfo.toggle() }) {
                        Label("Indicator Guide", systemImage: "info.circle")
                    }
                    .disabled(tasks.isEmpty ? true : false)
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(90))
                        .clipShape(.circle)
                }
            }
        }
        .padding(15)
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            /// Creating when it reaches the first/last page
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
        .sheet(isPresented: $showInfo) {
            infoView()
                .presentationDetents([.height(400)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
        }
        .sheet(isPresented: $showSettings) {
            settingsView()
                .interactiveDismissDisabled()
        }
        .fullScreenCover(isPresented: $showCalendarImport) {
            calendarImportView()
                .interactiveDismissDisabled()
        }
    }
    
    // MARK: Week View
    @ViewBuilder
    func weekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                let tasksForDay = tasks.filter { Calendar.current.isDate($0.creationDate, inSameDayAs: day.date) }
                
                VStack(spacing: 8) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                    
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : day.date.isToday ? .blue : .gray)
                        .frame(width: 35, height: 35)
                        .background {
                            if isSameDate(day.date, currentDate) {
                                Circle()
                                    .fill(.blue.gradient)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                            
                            /// Indicator to show, which is today's date
                            if day.date.isToday {
                                Circle()
                                    .fill(.blue.gradient)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                                
                            } else {
                                HStack(spacing: 3) {
                                    ForEach(tasksForDay.prefix(3).indices, id: \.self) { index in
                                        Circle()
                                            .fill(tasksForDay[index].tintColor)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                                .vSpacing(.bottom)
                                .offset(y: 12)
                            }
                        }
                        .background(Color(.systemGray6).shadow(.drop(radius: 1)), in: .circle)
                }
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    /// Updating current date
                    withAnimation(.snappy) {
                        currentDate = day.date
                    }
                }
            }
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear
                    .preference(key: offsetKey.self, value: minX)
                    .onPreferenceChange(offsetKey.self) { value in
                        if value.rounded() == 15 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }
    
    func paginateWeek() {
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                weekSlider.insert(firstDate.currentPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                weekSlider.append(lastDate.currentNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
        
        print(weekSlider.count)
    }
    
    func checkSubscription() {
        // Wait a tick if subscription state is loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if appSubModel.isSubscriptionActive {
                isPaywallPresented = false
            } else {
                isPaywallPresented = true
            }
            hasCheckedSubscription = true
        }
    }
    
    func generateWeek(for date: Date) -> [Date.WeekDay] {
        var week: [Date.WeekDay] = []
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                week.append(Date.WeekDay(date: day))
            }
        }
        return week
    }
    
    func indexOfCurrentWeek() -> Int? {
        let calendar = Calendar.current
        let today = Date()
        
        return weekSlider.firstIndex(where: { week in
            week.contains(where: { day in
                calendar.isDate(day.date, equalTo: today, toGranularity: .weekOfYear)
            })
        })
    }
    
    
}

#Preview {
    ContentView()
}
