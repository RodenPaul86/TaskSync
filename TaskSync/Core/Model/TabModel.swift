//
//  TabModel.swift
//  TaskSync
//
//  Created by Paul  on 11/10/24.
//

import SwiftUI

enum TabModel: String, CaseIterable {
    case home = "house"
    case search = "magnifyingglass"
    case settings = "gear"
    
    var title: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .settings: "Settings"
        }
    }
}
