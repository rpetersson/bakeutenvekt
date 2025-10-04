//
//  ContentView.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import SwiftUI

/// Main content view for the baking converter application
struct ContentView: View {
    @StateObject private var viewModel = BakingConverterViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        ingredientSelectionSection
                        gramInputSection
                        resultSection
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(nil) // Supports both light and dark mode
        }
    }
}

// MARK: - View Components
extension ContentView {
    
    /// Background gradient that adapts to color scheme
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color(.systemBackground), Color(.secondarySystemBackground)]
                : [Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.9, green: 0.94, blue: 0.98)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// Header section with app description
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue.gradient)
                .accessibilityHidden(true)
            
            Text("Convert grams to deciliters for baking")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }
    
    /// Ingredient selection section
    private var ingredientSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.blue)
                Text("Select Ingredient")
                    .font(.headline)
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Select ingredient section")
            
            IngredientPickerView(
                selectedIngredient: $viewModel.selectedIngredient,
                ingredients: viewModel.ingredients
            )
        }
        .cardStyle()
    }
    
    /// Gram input section with slider
    private var gramInputSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "scalemass")
                    .foregroundColor(.green)
                Text("Amount in Grams")
                    .font(.headline)
                Spacer()
                Text(viewModel.formattedGramAmount())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Amount in grams: \(viewModel.formattedGramAmount())")
            
            GramSliderView(gramAmount: $viewModel.gramAmount)
        }
        .cardStyle()
    }
    
    /// Result display section
    private var resultSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.orange)
                Text("Result")
                    .font(.headline)
                Spacer()
            }
            
            ResultDisplayView(
                result: viewModel.formattedDeciliterResult(),
                ingredient: viewModel.selectedIngredient.localizedName
            )
        }
        .cardStyle()
    }
}

// MARK: - View Modifiers
extension View {
    /// Applies card styling with background, padding, and shadow
    func cardStyle() -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}