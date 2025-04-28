//
//  IntroScreen.swift
//  TaskSync
//
//  Created by Paul  on 4/20/25.
//

import SwiftUI

struct IntroScreen: View {
    @Binding var showIntroView: Bool
    
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Welcome to \n\(Bundle.main.appName)")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding([.top, .bottom], 30)
            
            // MARK: Points
            VStack(alignment: .leading, spacing: 25) {
                keyPoints(image: "checkmark.seal", title: "Simple Task Management", description: "Create, edit, and organize your tasks with a simple and intuitive interface — no clutter, just focus.")
                
                keyPoints(image: "calendar", title: "Intelligent Weekly Planner", description: "Visualize and manage your week with a smart, swipeable calendar.")
                
                keyPoints(image: "arrow.trianglehead.2.clockwise.rotate.90", title: "Seamless Syncing", description: "Keep your tasks updated across all your devices in real time.")
                
                keyPoints(image: "party.popper", title: "Ad-Free Experience", description: "Thank you for downloading my app, I hope you enjoy it!")
            }
            .padding(.horizontal, 25)
            
            Spacer(minLength: 0)
            
            // MARK: Continue Button
            Button {
                showIntroView = true
                onContinue() /// <-- Trigger Paywall
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient, in: .capsule)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
        }
        .padding(15)
    }
    
    // MARK: Key Points
    @ViewBuilder
    private func keyPoints(image: String, title: String, description: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundStyle(Color.blue.gradient)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
        }
    }
}
