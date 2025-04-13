//
//  SubscriptionButton.swift
//  TaskSync
//
//  Created by Paul  on 4/12/25.
//

import SwiftUI
import RevenueCat

// MARK: Subscription Plans
enum SubscriptionPlan: String {
    case annual = "Annually"
    case monthly = "Monthly"
    case weekly = "Weekly"
    case lifetime = "Lifetime"
}

struct SubscriptionButton: View {
    let plan: SubscriptionPlan
    @Binding var selectedPlan: SubscriptionPlan
    var offering: Offering?
    
    @State private var currentOffering: Offering?
    @State private var originalYearlyPrice: Double = 259.48
    
    var isSelected: Bool {
        selectedPlan == plan
    }
    
    // MARK: Helper to extract price value
    func priceValue(for package: Package?) -> Double? {
        guard let price = package?.storeProduct.price as? NSDecimalNumber else { return nil }
        return price.doubleValue
    }
    
    // MARK: Helper to extract price
    func priceString(for plan: SubscriptionPlan) -> String {
        switch plan {
        case .annual:
            return offering?.annual?.localizedPriceString ?? "N/A"
        case .monthly:
            return offering?.monthly?.localizedPriceString ?? "N/A"
        case .weekly:
            return offering?.weekly?.localizedPriceString ?? "N/A"
        case .lifetime:
            return offering?.lifetime?.localizedPriceString ?? "N/A"
        }
    }
    
    // MARK: Calculate the dynamic discount for the Annual Plan
    func annualDiscount() -> Int? {
        let originalAnnualPrice: Double = originalYearlyPrice
        guard let discountedAnnualPrice = priceValue(for: offering?.annual) else { return nil }
        let discount = (1 - (discountedAnnualPrice / originalAnnualPrice)) * 100
        return Int(discount.rounded())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(plan.rawValue)
                    .foregroundColor(.white)
                    .font(.headline)
                
                if plan == .annual, let discount = annualDiscount() {
                    Spacer()
                    Text("-\(discount)%")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            Spacer()
            
            // Use helper function for price display
            let price = priceString(for: plan)
            
            // MARK: Display the appropriate price
            if plan == .annual {
                let originalPrice = String(originalYearlyPrice)
                
                Text("$\(originalPrice)")
                    .foregroundStyle(.blue)
                    .bold()
                    .strikethrough()
                
                Text("\(price) / yr")
                    .foregroundColor(.white)
                    .bold()
            } else if plan == .monthly {
                Text("\(price) / mo")
                    .foregroundColor(.white)
                    .bold()
            } else if plan == .weekly {
                Text("3-Day Trial")
                    .foregroundStyle(.blue)
                    .bold()
                
                Text("\(price) / wk")
                    .foregroundColor(.white)
                    .bold()
            } else if plan == .lifetime {
                Text("\(price) / one-time")
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: plan == .lifetime ? 100 : 100, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2)) /// <-- Dark gray background
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? .blue : .gray, lineWidth: 2)
        )
        .onTapGesture {
            selectedPlan = plan
        }
    }
}

#Preview {
    SubscriptionView(isPaywallPresented: .constant(false))
        .preferredColorScheme(.dark)
}
