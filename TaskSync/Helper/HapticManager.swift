//
//  HapticManager.swift
//  TaskSync
//
//  Created by Paul  on 4/21/25.
//

import UIKit

enum HapticType {
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selection
}

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func notify(_ type: HapticType) {
        switch type {
        case .notification(let feedback):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(feedback)
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
