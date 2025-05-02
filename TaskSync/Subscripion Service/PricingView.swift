//
//  PricingView.swift
//  TaskSync
//
//  Created by Paul  on 4/12/25.
//

import SwiftUI

struct PricingView: View {
    let features: [(name: String, free: String?, proType: ProFeatureType, freeHasAccess: Bool)] = [
        ("Syncing from Calendar", nil, .checkmark, false),
        ("Background Task Color", nil, .checkmark, false),
        ("Sync Across Devices", nil, .checkmark, true),
        ("Remove Annoying Paywalls", nil, .checkmark, false)
    ]
    
    enum ProFeatureType {
        case infinity, checkmark
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: Header
            HStack {
                Text("Features")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Free")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .frame(width: 50) /// <-- Fixed width for alignment
                
                Text("Pro")
                    .font(.headline.italic())
                    .foregroundStyle(Color.blue.gradient)
                    .frame(width: 50) /// <-- Fixed width for alignment
            }
            
            Divider()
            
            // MARK: Feature List
            ForEach(features, id: \.name) { feature in
                HStack {
                    // Feature Name
                    Text(feature.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Free Version Column
                    if let freeValue = feature.free {
                        Text(freeValue)
                            .frame(width: 50, alignment: .center)
                            .foregroundStyle(.gray)
                    } else {
                        Image(systemName: feature.freeHasAccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(feature.freeHasAccess ? Color.blue.gradient : Color.red.gradient)
                            .frame(width: 50)
                    }
                    
                    // Pro Version Column
                    Image(systemName: feature.proType == .infinity ? "infinity" : "checkmark.circle.fill")
                        .foregroundStyle(Color.blue.gradient)
                        .frame(width: 50)
                }
                .padding(.vertical, 5)
            }
            
            Divider()
            
            Text("Subscribe for $24.99/year or $4.99/week with a 3-day free trial. Weekly plans renew automatically unless canceled 24 hours before the trial ends. All subscriptions auto-renew unless canceled 24 hours before the current period ends. Manage or cancel anytime in your iTunes settings.")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .font(.subheadline)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    SubscriptionView(isPaywallPresented: .constant(false))
        .preferredColorScheme(.dark)
}
