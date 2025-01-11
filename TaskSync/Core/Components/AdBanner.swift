//
//  SubscriptionBannerView.swift
//  TaskSync
//
//  Created by Paul  on 12/30/24.
//

import SwiftUI

struct SubscriptionBannerView: View {
    @State private var isAdBannerVisible = true
    
    var body: some View {
        VStack {
            Spacer()
            /*
            if isAdBannerVisible {
                AdBanner(onDismiss: {
                    isAdBannerVisible = false
                })
            } else {
                PromoBanner()
            }
             */
        }
    }
}

struct AdBanner: View {
    var body: some View {
        HStack {
            Text("Upgrade for exclusive content and ad-free access.")
                .font(.footnote)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                // Handle subscription action
            }) {
                Text("Subscribe Now")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.9))
        .cornerRadius(10)
        .padding()
        .transition(.opacity)
        .animation(.easeInOut, value: true)
    }
}

struct PromoBanner: View {
    var body: some View {
        HStack {
            Text("Don't miss out on our latest updates!")
                .font(.footnote)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                // Handle promo action
            }) {
                Text("Learn More")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.9))
        .cornerRadius(10)
        .padding()
        .transition(.opacity)
        .animation(.easeInOut, value: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionBannerView()
    }
}
