//
//  IngredientPickerView.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import SwiftUI

/// A picker view for selecting baking ingredients
struct IngredientPickerView: View {
    @Binding var selectedIngredient: BakingIngredient
    let ingredients: [BakingIngredient]
    
    var body: some View {
        Menu {
            ForEach(ingredients, id: \.id) { ingredient in
                Button(action: {
                    selectedIngredient = ingredient
                }) {
                    HStack {
                        Text(ingredient.localizedName)
                        if ingredient.id == selectedIngredient.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedIngredient.localizedName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            )
        }
        .accessibilityLabel("Selected ingredient: \(selectedIngredient.localizedName)")
        .accessibilityHint("Tap to change ingredient")
    }
}

// MARK: - Preview
#Preview {
    @State var selectedIngredient = BakingIngredient.defaultIngredients[0]
    
    return VStack {
        IngredientPickerView(
            selectedIngredient: $selectedIngredient,
            ingredients: BakingIngredient.defaultIngredients
        )
        .padding()
        
        Text("Selected: \(selectedIngredient.localizedName)")
            .padding()
    }
}