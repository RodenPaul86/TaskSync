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
    @AppStorage("isSubscribed") var isPaywallPresented: Bool = false
    @State private var showIntro: Bool = false
    @State private var showPaywall: Bool = false
    
    var body: some View {
        Home()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if !hasSeenIntro {
                    showIntro = true
                } else if !isPaywallPresented {
                    showPaywall = true
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active && hasSeenIntro && !isPaywallPresented {
                    showPaywall = true
                }
            }
            .sheet(isPresented: $showIntro) {
                IntroScreen(showIntroView: $hasSeenIntro) {
                    hasSeenIntro = true
                    showIntro = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPaywall = true
                    }
                }
                .interactiveDismissDisabled()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                SubscriptionView(isPaywallPresented: $isPaywallPresented)
                    .preferredColorScheme(.dark)
            }
    }
}

#Preview {
    ContentView()
}
