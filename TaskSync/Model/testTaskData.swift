//
//  TaskData.swift
//  TaskSync
//
//  Created by Paul  on 11/7/24.
//

import SwiftUI

struct testTaskData: Identifiable {
    var id: UUID = UUID()
    var taskTitle: String
    var taskDescription: String
    var taskDate: Date
}
