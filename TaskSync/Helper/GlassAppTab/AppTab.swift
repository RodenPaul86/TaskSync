//
//  AppTab.swift
//  TaskSync
//
//  Created by Paul  on 9/13/25.
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home = 0
    case settings = 1
    case compose = 3
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .settings:
            return "Settings"
        case .compose:
            return "Compose"
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            return "list.bullet"
        case .settings:
            return "gear"
        case .compose:
            return "plus"
        }
    }
}
