//
//  AppRouter.swift
//  TaskSync
//
//  Created by Paul  on 9/13/25.
//

import SwiftUI

@Observable
class AppRouter {
    var selectedTab: AppTab
    var presentedSheet: PresentedSheet? /// <-- Ignore
    
    init(initialTab: AppTab = .home) {
        self.selectedTab = initialTab
    }
}

enum PresentedSheet: Identifiable { /// <-- Ignore
    case composer(mode: ComposerMode)
    
    var id: String {
        switch self {
        case .composer(let mode):
            return "composer-\(mode.rawValue)"
        }
    }
}

enum ComposerMode: String {
    case newPost = "newPost"
    case editPost = "editPost"
}
