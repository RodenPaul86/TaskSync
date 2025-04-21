//
//  ContentView.swift
//  TaskSync
//
//  Created by Paul  on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("showIntroView") private var hasSeenIntro: Bool = false
    
    @State private var showIntro: Bool = false
    @State private var isPaywallPresented: Bool = false
    
    @EnvironmentObject var appSubModel: appSubscriptionModel
    
    var body: some View {
        Home()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                checkAccessFlow()
            }
            .onChange(of: appSubModel.isLoading) { _, newValue in
                if !newValue {
                    checkAccessFlow()
                }
            }
            .task {
                // Refresh subscription when view loads
                appSubModel.refreshSubscriptionStatus()
            }
            .sheet(isPresented: $showIntro) {
                IntroScreen(showIntroView: $hasSeenIntro) {
                    hasSeenIntro = true
                    showIntro = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if !appSubModel.isSubscriptionActive {
                            isPaywallPresented = true
                        }
                    }
                }
                .interactiveDismissDisabled()
            }
            .fullScreenCover(isPresented: $isPaywallPresented) {
                SubscriptionView(isPaywallPresented: $isPaywallPresented)
                    .preferredColorScheme(.dark)
            }
    }
    
    private func checkAccessFlow() {
        if appSubModel.isLoading {
            return /// <-- wait until subscription status is loaded
        }
        
        if !hasSeenIntro {
            showIntro = true
        } else if !appSubModel.isSubscriptionActive {
            isPaywallPresented = true
        } else {
            isPaywallPresented = false
        }
    }
}
