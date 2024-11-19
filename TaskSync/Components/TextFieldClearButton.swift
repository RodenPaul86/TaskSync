//
//  TextFieldClearButton.swift
//  TaskSync
//
//  Created by Paul  on 11/15/24.
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
                .offset(x: 25)
            }
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(TextFieldClearButton(text: text))
            .padding(.leading, 12)
            .padding(.trailing, 35)
            .padding(.vertical, 12)
    }
}

    
