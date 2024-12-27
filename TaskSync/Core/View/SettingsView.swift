//
//  SettingsView.swift
//  TaskSync
//
//  Created by Paul  on 12/25/24.
//

import SwiftUI

struct BooleanSetting: Identifiable {
    var id: String {
        key
    }
    let title: String
    let key: String
    let defaultValue: Bool
}

struct ToggleRow: View {
    private var setting: AppStorage<Bool>
    private var settingValue: Bool {
        setting.wrappedValue
    }
    let title: String
    init(_ booleanSetting: BooleanSetting) {
        self.title = booleanSetting.title
        self.setting = AppStorage(wrappedValue: booleanSetting.defaultValue, booleanSetting.key)
    }
    var body: some View {
        Toggle(title + " is \(settingValue ? "on" : "off")", isOn: setting.projectedValue)
    }
}


struct SettingsView: View {
    let settings: [BooleanSetting] = [
        BooleanSetting(title: "Setting 1", key: "settingone", defaultValue: true)
    ]
    var body: some View {
        Form {
            ForEach(settings) { setting in
                ToggleRow(setting)
            }
        }
    }
}

#Preview {
    SettingsView()
}
