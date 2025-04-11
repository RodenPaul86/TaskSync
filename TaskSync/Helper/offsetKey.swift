//
//  offsetKey.swift
//  TaskSync
//
//  Created by Paul  on 3/30/25.
//

import SwiftUI

struct offsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
