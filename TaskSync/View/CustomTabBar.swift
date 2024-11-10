//
//  CustomTabBar.swift
//  TaskSync
//
//  Created by Paul  on 11/10/24.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var activeTab: TabModel
    
    var body: some View {
        ForEach(TabModel.allCases, id: \.rawValue) { tab in
            Button {
                
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: tab.rawValue)
                        .font(.title3.bold())
                        .frame(width: 30, height: 30)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ContentView()
}
