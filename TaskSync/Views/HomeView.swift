//
//  Home.swift
//  TaskSync
//
//  Created by Paul  on 3/30/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // MARK: Paywall Properties
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @State private var isPaywallPresented: Bool = false
    
    // MARK: Properties
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var createTask: Bool = false
    @State private var showInfo: Bool = false
    @State private var showSettings: Bool = false
    @Namespace private var animation
    
    @Query var tasks: [Task] /// <-- Ensure this fetches all tasks

    var tasksForSelectedDate: [Task] {
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
            if appSubModel.isSubscriptionActive {
                isPaywallPresented = false
            } else {
                isPaywallPresented = true
            }
            
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
        }
        .sheet(isPresented: $createTask) {
            NewTaskView()
                .presentationDetents([.height(400)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
        }
        .fullScreenCover(isPresented: $isPaywallPresented) {
            SubscriptionView(isPaywallPresented: $isPaywallPresented)
                .preferredColorScheme(.dark)
        }
    }
    
    // MARK: Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(currentDate.format("MMMM"))
                    .foregroundStyle(.blue)
                
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
                Text("You have \(incompleteTasks.count) task\(incompleteTasks.count > 1 ? "s" : "") to tackle today.")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            
            // Display expired tasks
            if !expiredTasks.isEmpty {
                Text("You have \(expiredTasks.count) expired task\(expiredTasks.count > 1 ? "s" : "").")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }
            
            if incompleteTasks.isEmpty && expiredTasks.isEmpty {
                Text("There's nothing to do today!")
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
            Menu {
                Button(action: {}) {
                    Label("Sync Calender", systemImage: "square.and.arrow.down.badge.clock")
                }
                .disabled(appSubModel.isSubscriptionActive ? false : true)
                
                Button(action: { showSettings.toggle() }) {
                    Label("Settings", systemImage: "gear")
                }
                
                Button(action: { showInfo.toggle() }) {
                    Label("Color Guide", systemImage: "info.circle")
                }
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(.circle)
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
        }
    }
    
    // MARK: Week View
    @ViewBuilder
    func weekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                let tasksForDay = tasks.filter { Calendar.current.isDate($0.creationDate, inSameDayAs: day.date) }
                let taskTintColor = tasksForDay.first?.tintColor ?? .clear // Use first task's color
                
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
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .gray)
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
                                    .fill(.blue)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                                
                            } else {
                                Circle()
                                    .fill(taskTintColor)
                                    .frame(width: 5, height: 5)
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
}

#Preview {
    ContentView()
}
