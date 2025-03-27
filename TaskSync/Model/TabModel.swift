//
//  Untitled.swift
//  TaskSync
//
//  Created by Paul  on 3/24/25.
//

import SwiftUI

enum TabModel: String, CaseIterable {
    case today = "Today"
    case upcoming = "Upcoming"
    case complete = "Complete"
    case expired = "Expired"
    case allTask = "All Tasks"
    
    var color: Color {
        switch self {
        case .today: .blue
        case .upcoming: .orange
        case .complete: .green
        case .expired: .red
        case .allTask: Color.primary
        }
    }
    
    var symbolImage: String {
        switch self {
        case .today: "calendar"
        case .upcoming: "clock"
        case .complete: "checkmark.circle"
        case .expired: "xmark.circle"
        case .allTask: "tray.full"
        }
    }
}
