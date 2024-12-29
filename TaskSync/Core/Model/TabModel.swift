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
    case premium = "star"
    case settings = "gear"
    
    var title: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .premium: "Premium"
        case .settings: "Settings"
        }
    }
}
