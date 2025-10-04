//
//  ResultDisplayView.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import SwiftUI

/// A view that displays the conversion result with visual emphasis
struct ResultDisplayView: View {
    let result: String
    let ingredient: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Main result display
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Equals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(result)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange.gradient)
                        .contentTransition(.numericText())
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.orange.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Additional context
            Text("of **\(ingredient)**")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Result: \(result) of \(ingredient)")
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ResultDisplayView(
            result: "1.67 dl",
            ingredient: "Hvetemel"
        )
        .padding()
        
        ResultDisplayView(
            result: "2.50 dl",
            ingredient: "Havregryn"
        )
        .padding()
    }
}