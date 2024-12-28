//
//  Settings.swift
//  TaskSync
//
//  Created by Paul  on 12/27/24.
//

import SwiftUI
import UserNotifications

@available(iOS 18.0, *)
struct Settings: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("sortOption") private var sortOption: String = "Priority"
    @AppStorage("startOfWeek") private var startOfWeek: String = "Sunday"
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("notificationTime") private var notificationTime: Date = defaultNotificationTime
    @AppStorage("selectedAppIcon") private var selectedAppIcon: String = "Default"
    @AppStorage("customSound") private var customSound: String = "Chime"
    @AppStorage("isiCloudSyncEnabled") private var isiCloudSyncEnabled: Bool = true
    @AppStorage("faceIDEnabled") private var faceIDEnabled: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "English"
    
    let sortOptions = ["Priority", "Due Date", "Creation Date"]
    let weekStartOptions = ["Sunday", "Monday"]
    let appIcons = ["Default", "Alternate 1", "Alternate 2"]
    let sounds = ["Chime", "Bell", "Silent"]
    let languages = ["English", "Spanish", "French"]
    
    static var defaultNotificationTime: Date {
        // Default to 9:00 AM
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            Form {
                // User Preferences
                Section(header: Text("User Preferences")) {
                    //Toggle("Dark Mode", isOn: $isDarkMode)
                    Picker("Sort Tasks By", selection: $sortOption) {
                        ForEach(sortOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    Picker("Start of the Week", selection: $startOfWeek) {
                        ForEach(weekStartOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                }
                
                // Notifications
                Section {
                    Toggle("Enable Daily Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) {
                            if notificationsEnabled {
                                // Re-enable notifications
                                NotificationManager.shared.requestNotificationPermissions { granted in
                                    if !granted {
                                        notificationsEnabled = false
                                    }
                                }
                            } else {
                                // Disable notifications
                                NotificationManager.shared.cancelAllNotifications()
                            }
                        }
                    if notificationsEnabled {
                        DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) { oldTime, newTime in
                                print("Notification time changed from \(oldTime) to \(newTime)")
                                NotificationManager.shared.scheduleDailyNotification(at: newTime)
                            }
                        Picker("Notification Sound", selection: $customSound) {
                            ForEach(sounds, id: \.self) { sound in
                                Text(sound.capitalized) // Optional: Capitalize the sound names for better display
                            }
                        }
                        .onChange(of: customSound) { oldSound, newSound in
                            if notificationsEnabled {
                                let soundName = Bundle.main.path(forResource: newSound, ofType: "wav") != nil ? "\(newSound).wav" : "default"
                                NotificationManager.shared.scheduleDailyNotification(at: notificationTime, soundName: soundName)
                            }
                        }
                    }
                    
                } header: {
                    Text("Notifications")
                    
                } footer: {
                    Text("Turn on a daily reminder to receive notifications at your preferred time.")
                }
                
                // Customization
                Section(header: Text("Customization")) {
                    Picker("App Icon", selection: $selectedAppIcon) {
                        ForEach(appIcons, id: \.self) { icon in
                            Text(icon)
                        }
                    }
                }
                /*
                // Data Management
                Section(header: Text("Data Management")) {
                    Toggle("iCloud Sync", isOn: $isiCloudSyncEnabled)
                    Button("Backup Data") {
                        // Implement backup functionality
                    }
                    Button("Export Tasks as CSV") {
                        // Implement export functionality
                    }
                    Button("Clear Completed Tasks") {
                        // Implement task clearing functionality
                    }
                }
                
                // Security
                Section(header: Text("Security")) {
                    Toggle("Enable Face ID", isOn: $faceIDEnabled)
                }
                */
                // Support
                Section(header: Text("Support")) {
                    NavigationLink("Help & FAQ", destination: HelpFAQView())
                    NavigationLink("Contact Support", destination: ContactSupportView())
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.gray)
                    }
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
        isDarkMode = false
        sortOption = "Priority"
        startOfWeek = "Sunday"
        notificationsEnabled = false
        //notificationTime = Date = defaultNotificationTime
        selectedAppIcon = "Default"
        customSound = "Chime"
        isiCloudSyncEnabled = true
        faceIDEnabled = false
        selectedLanguage = "English"
    }
}

// Placeholder views for navigation links

struct ContactSupportView: View {
    var body: some View {
        Text("Contact Support")
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        Settings()
    } else {
        // Fallback on earlier versions
    }
}
