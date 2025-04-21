//
//  HapticManager.swift
//  TaskSync
//
//  Created by Paul  on 4/21/25.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
