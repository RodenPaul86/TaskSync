//
//  CustomTabBar.swift
//  TaskSync
//
//  Created by Paul  on 11/10/24.
//

import SwiftUI

struct CustomTabBar: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    
    var activeForeground: Color = .white
    var activeBackground: Color = .black
    @Binding var activeTab: TabModel
    
    // For Matched Geometry Effect
    @Namespace private var animation
    
    // View Properties
    @State private var tabLocation: CGRect = .zero
    
    var body: some View {
        let status = activeTab == .home || activeTab == .search || activeTab == .settings
        
        HStack(spacing: !status ? 0 : 12) {
            HStack(spacing: 0) {
                ForEach(TabModel.allCases, id: \.rawValue) { tab in
                    Button {
                        activeTab = tab
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tab.rawValue)
                                .font(.title3.bold())
                                .frame(width: 30, height: 30)
                            
                            if activeTab == tab {
                                Text(tab.title)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                        }
                        .foregroundStyle(activeTab == tab ? activeForeground : .gray)
                        .padding(.vertical, 2)
                        .padding(.leading, 10)
                        .padding(.trailing, 15)
                        .contentShape(.rect)
                        .background {
                            if activeTab == tab {
                                Capsule()
                                    .fill(.clear)
                                    .onGeometryChange(for: CGRect.self, of: {
                                        $0.frame(in: .named("TABBARVIEW"))
                                    }, action: { newValue in
                                        tabLocation = newValue
                                    })
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(alignment: .leading) {
                Capsule()
                    .fill(activeBackground.gradient)
                    .frame(width: tabLocation.width, height: tabLocation.height)
                    .offset(x: tabLocation.minX)
            }
            .coordinateSpace(.named("TABBARVIEW"))
            .padding(.horizontal, 5)
            .frame(height: 45)
            .background(
                .background
                    .shadow(.drop(color: .black.opacity(0.08), radius: 5, x: 5, y: 5))
                    .shadow(.drop(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)),
                in: .capsule
            )
            .zIndex(10)
            
            // MARK: Add new task button
            Button {
                if activeTab == .home {
                    print("Plus Sign")
                    taskModel.addNewTask.toggle()
                } else if activeTab == .search {
                    print("Microphone Search")
                } else {
                    print("Account Profile")
                }
            } label: {
                MorphingSymbolView(symbol: activeTab == .home ? "plus" : activeTab == .search ? "mic.fill" : "crown.fill",
                                   config: .init(font: .title3,
                                                 frame: .init(width: 42, height: 42),
                                                 radius: 2,
                                                 foregroundColor: activeForeground,
                                                 keyframeDuration: 0.3,
                                                 symbolAnimation: .smooth(duration: 0.3, extraBounce: 0))
                )
                .background(activeBackground.gradient)
                .clipShape(.circle)
            }
            .allowsHitTesting(status)
            .offset(x: status ? 0 : -20)
            .padding(.leading, status ? 0 : -42)
            .sheet(isPresented: $taskModel.addNewTask) {
                // Clearing Edit Data
                taskModel.editTask = nil
            } content: {
                NewTaskView()
                    .interactiveDismissDisabled(true)  // Disabling Dismiss on Swipe
                    .environmentObject(taskModel)
            }
        }
        .padding(.bottom)
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
    }
}

#Preview {
    ContentView()
}
