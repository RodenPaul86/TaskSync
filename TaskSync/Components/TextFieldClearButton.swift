//
//  TextFieldClearButton.swift
//  TaskSync
//
//  Created by Paul  on 3/29/25.
//

import SwiftUI

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundStyle(.gray)
                }
                .offset(x: 35)
            }
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(TextFieldClearButton(text: text))
            .padding(.trailing, 35) // Extra space for the button
            .frame(maxWidth: .infinity) // Ensure it takes the full available width
    }
}
