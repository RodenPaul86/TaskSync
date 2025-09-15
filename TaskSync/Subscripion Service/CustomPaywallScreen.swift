//
//  CustomPaywallScreen.swift
//  TaskSync
//
//  Created by Paul  on 9/14/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct CustomPaywallScreen: View {
    @EnvironmentObject var subscriptionModel: appSubscriptionModel
    @State private var offering: Offering?
    
    var body: some View {
        VStack {
            if let offering {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top)
                        
                        Text("Enjoy all the extra features by subscribing to Premium.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                // 🚀 RevenueCat footer
                .originalTemplatePaywallFooter(
                    offering: offering,
                    condensed: false
                ) { customerInfo in
                    // Update your model when purchase completes
                    //let isActive = customerInfo.entitlements.all["premium"]?.isActive == true
                    //subscriptionModel.updateSubscriptionStatus(isActive: isActive)
                }
            } else {
                ProgressView("Loading…")
                    .task {
                        do {
                            let offerings = try await Purchases.shared.offerings()
                            offering = offerings.current
                        } catch {
                            print("Error fetching offerings: \(error)")
                        }
                    }
            }
        }
    }
}

#Preview {
    CustomPaywallScreen()
}
