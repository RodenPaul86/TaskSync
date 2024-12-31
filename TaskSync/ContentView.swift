//
//  ContentView.swift
//  TaskSync
//
//  Created by Paul  on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    // MARK: View Properties
    @State private var activeTab: TabModel = .home
    @State private var isTabBarHidden: Bool = false
    
    @State private var isSearching: Bool = false
    @State private var filteredTasks: [Task] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if #available(iOS 18.0, *) {
                    TabView(selection: $activeTab) {
                        Tab.init(value: .home) {
                            Home()
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab.init(value: .search) {
                            SearchView(isSearching: $isSearching, filteredTasks: $filteredTasks)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab.init(value: .whatsNew) {
                            WhatsNewView()
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab.init(value: .settings) {
                            Settings()
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                } else {
                    TabView(selection: $activeTab) {
                        Home()
                            .tag(TabModel.home)
                            .background {
                                if !isTabBarHidden {
                                    HideTabBar {
                                        print("Hidden")
                                        isTabBarHidden = true
                                    }
                                }
                            }
                        Text("Search")
                            .tag(TabModel.search)
                        
                        Text("What's New")
                            .tag(TabModel.whatsNew)
                        
                        Text("Settings")
                            .tag(TabModel.settings)
                    }
                }
            }
            CustomTabBar(activeTab: $activeTab)
            /*
            AdBanner()
                .safeAreaPadding(.bottom, 60)
             */
        }
    }
}

struct HideTabBar: UIViewRepresentable {
    init(result: @escaping () -> Void) {
        UITabBar.appearance().isHidden = true
        self.result = result
    }
    
    var result: () -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let tabController = view.tabController {
                tabController.tabBar.isHidden = true
                result()
            }
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {  }
}

extension UIView {
    var tabController: UITabBarController? {
        if let controller = sequence(first: self, next: {
            $0.next
        }).first(where: { $0 is UITabBarController }) as? UITabBarController {
            return controller
        }
        return nil
    }
}

#Preview {
    ContentView()
}
