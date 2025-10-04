//
//  GramSliderView.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import SwiftUI

/// A slider view for selecting gram amounts with haptic feedback
struct GramSliderView: View {
    @Binding var gramAmount: Double
    @State private var isDragging = false
    
    private let minValue: Double = 1.0
    private let maxValue: Double = 1000.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Slider
            HStack {
                Text("\(Int(minValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: $gramAmount,
                    in: minValue...maxValue,
                    step: 1.0
                ) { editing in
                    isDragging = editing
                    if !editing {
                        // Provide haptic feedback when user stops dragging
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                }
                .tint(.green)
                .accessibilityLabel("Gram amount slider")
                .accessibilityValue("\(Int(gramAmount)) grams")
                
                Text("\(Int(maxValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Quick selection buttons
            quickSelectionButtons
        }
    }
}

// MARK: - Components
extension GramSliderView {
    
    /// Quick selection buttons for common amounts
    private var quickSelectionButtons: some View {
        HStack(spacing: 12) {
            ForEach([50, 100, 200, 250, 500], id: \.self) { amount in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        gramAmount = Double(amount)
                    }
                    
                    // Haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }) {
                    Text("\(amount)g")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(gramAmount == Double(amount) ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(gramAmount == Double(amount) ? .blue : .blue.opacity(0.1))
                        )
                }
                .accessibilityLabel("\(amount) grams")
                .accessibilityHint("Set amount to \(amount) grams")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @State var gramAmount: Double = 100
    
    return VStack {
        GramSliderView(gramAmount: $gramAmount)
            .padding()
        
        Text("Current: \(Int(gramAmount))g")
            .padding()
    }
}