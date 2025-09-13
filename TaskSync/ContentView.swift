//
//  ContentView.swift
//  TaskSync
//
//  Created by Paul  on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppRouter.self) var router
    let tabs: [AppTab] = AppTab.allCases
    @Binding var showComposeOverlay: Bool
    var composeNamespace: Namespace.ID /// <-- receive namespace
    
    var body: some View {
        @Bindable var router = router
        if #available(iOS 26.0, *) {
            TabView(selection: $router.selectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Tab(value: tab, role: tab == .compose ? .search : nil) {
                        AppTabRootView(tab: tab)
                    } label: {
                        if tab == .compose {
                            Label(tab.title, systemImage: tab.icon)
                                .matchedTransitionSource(id: "compose-tab", in: composeNamespace)
                        } else {
                            Label(tab.title, systemImage: tab.icon)
                        }
                    }
                }
            }
            .onChange(of: router.selectedTab) { oldTab, newTab in
                if newTab == .compose {
                    withAnimation { showComposeOverlay = true }
                    router.selectedTab = oldTab
                }
            }
            .sheet(isPresented: $showComposeOverlay) {
                NewTaskView()
                    .presentationDetents([.height(400)])
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(30)
            }
        } else {
            // MARK: iOS 18 fallback
            TabView(selection: $router.selectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    AppTabRootView(tab: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                }
            }
            .onChange(of: router.selectedTab) { oldTab, newTab in
                if newTab == .compose {
                    withAnimation { showComposeOverlay = true }
                    router.selectedTab = oldTab
                }
            }
            .sheet(isPresented: $showComposeOverlay) {
                NewTaskView()
                    .presentationDetents([.height(400)])
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(30)
            }
        }
    }
}
