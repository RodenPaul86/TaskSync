//
//  Home.swift
//  TaskSync
//
//  Created by Paul  on 3/8/25.
//

import SwiftUI

struct Home: View {
    @StateObject var taskModel: TaskViewModel = .init()
    @Namespace var animation
    
    // MARK: Main View
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcom Back")
                        .font(.callout)
                    Text("Here's Update Today.")
                        .font(.title2.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
                
                CustomSegmentedBar()
                    .padding(.top, 5)
                
                // TODO: Task View
                
                
                
                
                
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            // MARK: ADD Button
            Button {
                
            } label: {
                Label {
                    Text("Add Task")
                        .font(.callout)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "plus.app.fill")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(.black, in: Capsule())
            }
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
            .background {
                LinearGradient(colors: [
                    .white.opacity(0.05),
                    .white.opacity(0.4),
                    .white.opacity(0.7),
                    .white
                ], startPoint: .top, endPoint: .bottom)
            }
        }
    }
    
    // MARK: Custom Segmented Bar
    @ViewBuilder
    func CustomSegmentedBar() -> some View {
        let tabs = ["Today", "Upcoming", "Task Done", "Failed"]
        HStack(spacing: 10) {
            ForEach(tabs, id: \.self) { tab in
                Text(tab)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .scaleEffect(0.9)
                    .foregroundColor(taskModel.currentTab == tab ? .white : .black)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background {
                        if taskModel.currentTab == tab {
                            Capsule()
                                .fill(.black)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation { taskModel.currentTab = tab }
                    }
                
            }
        }
    }
    
}

#Preview {
    Home()
}
