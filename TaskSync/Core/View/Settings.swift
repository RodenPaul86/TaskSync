//
//  Settings.swift
//  TaskSync
//
//  Created by Paul  on 12/27/24.
//

import SwiftUI
import UserNotifications

struct Settings: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("sortOption") private var sortOption: String = "Priority"
    @AppStorage("startOfWeek") private var startOfWeek: String = "Sunday"
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("notificationTime") private var notificationTime: Double = Date().timeIntervalSince1970
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
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: Binding(
                        get: { notificationsEnabled },
                        set: { newValue in
                            notificationsEnabled = newValue
                            handleNotificationToggle(isEnabled: newValue)
                        }
                    ))
                    if notificationsEnabled {
                        DatePicker(
                            "Notification Time",
                            selection: Binding(
                                get: { Date(timeIntervalSince1970: notificationTime) },
                                set: {
                                    notificationTime = $0.timeIntervalSince1970
                                    if notificationsEnabled {
                                        NotificationManager.shared.scheduleDailyNotification(at: $0, soundName: "\(customSound).wav")
                                    }
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                // Customization
                Section(header: Text("Customization")) {
                    Picker("App Icon", selection: $selectedAppIcon) {
                        ForEach(appIcons, id: \.self) { icon in
                            Text(icon)
                        }
                    }
                    Picker("Notification Sound", selection: $customSound) {
                        ForEach(sounds, id: \.self) { sound in
                            Text(sound)
                        }
                    }
                    .onChange(of: customSound) {
                        if notificationsEnabled {
                            let time = Date(timeIntervalSince1970: notificationTime)
                            NotificationManager.shared.scheduleDailyNotification(at: time, soundName: "\(customSound).wav")
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
                /*
                // Miscellaneous
                Section(header: Text("Miscellaneous")) {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language)
                        }
                    }
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                }
                 */
            }
            .navigationTitle("Settings")
            .safeAreaPadding(.bottom, 60)
        }
    }
    
    // Handle Notifications Toggle
    private func handleNotificationToggle(isEnabled: Bool) {
        if isEnabled {
            NotificationManager.shared.requestNotificationPermissions { granted in
                if granted {
                    let time = Date(timeIntervalSince1970: notificationTime)
                    NotificationManager.shared.scheduleDailyNotification(at: time, soundName: "\(customSound).wav")
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
    
    // Function to reset settings to defaults
    private func resetToDefaults() {
        isDarkMode = false
        sortOption = "Priority"
        startOfWeek = "Sunday"
        notificationsEnabled = true
        notificationTime = Date().timeIntervalSince1970
        selectedAppIcon = "Default"
        customSound = "Chime"
        isiCloudSyncEnabled = true
        faceIDEnabled = false
        selectedLanguage = "English"
    }
}

// Placeholder views for navigation links
struct HelpFAQView: View {
    var body: some View {
        Text("Help & FAQ")
    }
}

struct ContactSupportView: View {
    var body: some View {
        Text("Contact Support")
    }
}

#Preview {
    Settings()
}
