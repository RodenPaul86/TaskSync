//
//  Settings.swift
//  TaskSync
//
//  Created by Paul  on 12/27/24.
//

import SwiftUI
import UserNotifications

struct Settings: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel() // Observing TaskViewModel
    
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("sortOption") private var sortOption: String = "Due Date"
    @AppStorage("startOfWeek") private var startOfWeek: String = "Sunday"
    @AppStorage("selectedAppIcon") private var selectedAppIcon: String = "Default"
    
    @AppStorage("faceIDEnabled") private var faceIDEnabled: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "English"
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("priorityNotifications") private var priorityNotifications = false
    @AppStorage("alertSound") private var alertSound: String = "Default"
    
    let weekStartOptions = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let appIcons = ["Default", "Alternate 1", "Alternate 2"]
    let sounds = ["Default", "Chime", "Doorbell", "Alert-1", "Alert-2"]
    let languages = ["English", "Spanish", "French"]
    
    
    
    var body: some View {
        NavigationStack {
            Form {
                // User Preferences
                Section(header: Text("General")) {
                    //Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(.orange)
                                .frame(width: 30, height: 30)
                            Image(systemName: "arrow.trianglehead.counterclockwise.icloud.fill").foregroundColor(.white)
                        }
                        NavigationLink("iCloud Sync", destination: iCloudSync())
                    }
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(.red)
                                .frame(width: 30, height: 30)
                            Image(systemName: "bell.badge.fill").foregroundColor(.white)
                        }
                        NavigationLink("Notification & Alerts", destination: Text("Notification & Alerts"))
                    }
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(.green)
                                .frame(width: 30, height: 30)
                            Image(systemName: "paintbrush.fill").foregroundColor(.white)
                        }
                        NavigationLink("Customization", destination: Text("Customization"))
                    }
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(.blue)
                                .frame(width: 30, height: 30)
                            Image(systemName: "gearshape.2.fill").foregroundColor(.white)
                        }
                        NavigationLink("Advanced", destination: Text("Advanced"))
                    }
                }
                
                // MARK: Notifications
                Section(header: Text("Notifications")){
                    Toggle("Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            NotificationManager.shared.toggleNotifications(enable: newValue)
                        }
                    
                    Text("Reminders for tasks")
                    Text("Snooze options")
                    Text("Daily Summary")
                    
                    /*
                    if notificationsEnabled {
                        Picker("Alert Sound", selection: $alertSound) {
                            ForEach(sounds, id: \.self) { sound in
                                Text(sound).tag(sound)
                            }
                        }
                        
                        Toggle("Priority Notifications", isOn: $priorityNotifications)
                    }
                     */
                }
                
                Section(header: Text("Task Preferences")) {
                    Picker("Start of the Week", selection: $startOfWeek) {
                        ForEach(weekStartOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    
                    Text("Task Priority")
                    
                    Picker("Sort Task By", selection: $sortOption) {
                        ForEach(TaskSortCriteria.allCases, id: \.self) { criteria in
                            Text(criteria.rawValue).tag(criteria.rawValue)
                        }
                    }
                }
                
                // Customization
                Section(header: Text("Customization")) {
                    Picker("App Icon", selection: $selectedAppIcon) {
                        ForEach(appIcons, id: \.self) { icon in
                            Text(icon)
                        }
                    }
                }
                
                
                
                // Security
                Section(header: Text("Security")) {
                    Toggle("Enable Face ID", isOn: $faceIDEnabled)
                }
                
                // Support
                Section(header: Text("Support")) {
                    NavigationLink("Help & FAQ", destination: HelpFAQ())
                }
                
                Section(header: Text("Legal")) {
                    NavigationLink("Privacy Policy", destination: Text("Privacy Policy"))
                    NavigationLink("Terms of Service", destination: Text("Terms of Service"))
                    NavigationLink("Developer credits", destination: Text("Developer credits"))
                }
                
                // Miscellaneous
                Section(header: Text("Miscellaneous")) {
                    /*
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language)
                        }
                    }
                     */
                    Button("Reset") {
                        resetToDefaults()
                    }
                }
            }
            .navigationTitle("Settings")
            .safeAreaPadding(.bottom, 60)
            .onAppear {
                // Ensure notifications are synced with system settings
                syncNotificationStatus()
            }
        }
    }
    
    private func syncNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    /*
    // Handle Notifications Toggle
    private func handleNotificationToggle(isEnabled: Bool) {
        if isEnabled {
            NotificationManager.shared.requestNotificationPermissions { granted in
                if granted {
                    let time = Date(timeIntervalSince1970: notificationTime)
                    //NotificationManager.shared.scheduleDailyNotification(at: time, soundName: "\(customSound).wav")
                } else {
                    DispatchQueue.main.async {
                        notificationsEnabled = false
                    }
                }
            }
        } else {
            NotificationManager.shared.cancelNotification(withIdentifier: "dailyReminder")
        }
    }
    */
    // Function to reset settings to defaults
    private func resetToDefaults() {
        //isDarkMode = false
        sortOption = "Due Date"
        startOfWeek = "Sunday"
        notificationsEnabled = true
        //selectedAppIcon = "Default"
        //isiCloudSyncEnabled = true
        //faceIDEnabled = false
        //selectedLanguage = "English"
        //priorityNotifications = false
        //alertSound = "Chime"
    }
}

#Preview {
    Settings()
}

struct ReusableSection: View {
    let title: String
    let icon: Image?
    let iconBackgroundColor: Color
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(iconBackgroundColor)
                    .frame(width: 28, height: 28)
                    .cornerRadius(5)
                icon
                    .foregroundColor(.white)
            }
            Text(title)
        }
    }
}
