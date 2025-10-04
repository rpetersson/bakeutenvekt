//
//  BakingApp.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

// MARK: - Models

/// Represents a baking ingredient with its name and density
struct BakingIngredient: Hashable, Identifiable, Codable {
    var id: String { name }
    let name: String
    let gramsPerDeciliter: Int
    
    /// Localized display name based on current locale
    var localizedName: String {
        NSLocalizedString("ingredient.\(name.lowercased().replacingOccurrences(of: " ", with: "_"))", 
                         value: name, 
                         comment: "Localized name for ingredient \(name)")
    }
    
    /// Converts grams to deciliters for this ingredient
    /// - Parameter grams: Amount in grams
    /// - Returns: Amount in deciliters
    func convertGramsToDeciliters(_ grams: Double) -> Double {
        guard gramsPerDeciliter > 0 else { return 0 }
        return grams / Double(gramsPerDeciliter)
    }
    
    /// Converts deciliters to grams for this ingredient
    /// - Parameter deciliters: Amount in deciliters
    /// - Returns: Amount in grams
    func convertDecilitersToGrams(_ deciliters: Double) -> Double {
        return deciliters * Double(gramsPerDeciliter)
    }
    
    /// Default collection of common baking ingredients
    static let defaultIngredients: [BakingIngredient] = [
        BakingIngredient(name: "Hvetemel", gramsPerDeciliter: 60),
        BakingIngredient(name: "Grovt mel", gramsPerDeciliter: 55),
        BakingIngredient(name: "Havregryn", gramsPerDeciliter: 40),
        BakingIngredient(name: "Maizena", gramsPerDeciliter: 50),
        BakingIngredient(name: "Potetmel", gramsPerDeciliter: 70),
        BakingIngredient(name: "Salt", gramsPerDeciliter: 230),
        BakingIngredient(name: "Sukker", gramsPerDeciliter: 90),
        BakingIngredient(name: "Melis", gramsPerDeciliter: 60),
        BakingIngredient(name: "Sirup", gramsPerDeciliter: 120),
        BakingIngredient(name: "Rosiner", gramsPerDeciliter: 60),
        BakingIngredient(name: "Margarin", gramsPerDeciliter: 90),
        BakingIngredient(name: "Olje", gramsPerDeciliter: 90),
        BakingIngredient(name: "Smulegryn", gramsPerDeciliter: 70),
        BakingIngredient(name: "Ris, langkornet", gramsPerDeciliter: 80),
        BakingIngredient(name: "Ris rundkornet", gramsPerDeciliter: 90),
        BakingIngredient(name: "Erter, Bønner, Linser", gramsPerDeciliter: 80),
        BakingIngredient(name: "Kakao", gramsPerDeciliter: 40),
        BakingIngredient(name: "Kokosmasse", gramsPerDeciliter: 40),
        BakingIngredient(name: "Syltetøy", gramsPerDeciliter: 125),
        BakingIngredient(name: "Hvit-ost revet", gramsPerDeciliter: 40)
    ]
}

// MARK: - ViewModel

/// ViewModel for the baking converter, handling business logic and state management
@MainActor
final class BakingConverterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedIngredient: BakingIngredient
    @Published var gramAmount: Double = 100.0
    @Published var deciliterResult: Double = 0.0
    @Published var ingredients: [BakingIngredient]
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(ingredients: [BakingIngredient] = BakingIngredient.defaultIngredients) {
        let sortedIngredients = ingredients.sorted { $0.localizedName < $1.localizedName }
        self.ingredients = sortedIngredients
        self.selectedIngredient = sortedIngredients.first ?? BakingIngredient(name: "Unknown", gramsPerDeciliter: 60)
        
        setupBindings()
        calculateResult()
    }
    
    // MARK: - Public Methods
    
    /// Updates the selected ingredient and recalculates the result
    /// - Parameter ingredient: The newly selected ingredient
    func selectIngredient(_ ingredient: BakingIngredient) {
        selectedIngredient = ingredient
    }
    
    /// Updates the gram amount and recalculates the result
    /// - Parameter grams: The new amount in grams
    func updateGramAmount(_ grams: Double) {
        gramAmount = max(0, grams) // Ensure non-negative
    }
    
    /// Formats the gram amount for display
    /// - Returns: Formatted string with "g" suffix
    func formattedGramAmount() -> String {
        String(format: "%.0f g", gramAmount)
    }
    
    /// Formats the deciliter result for display
    /// - Returns: Formatted string with "dl" suffix
    func formattedDeciliterResult() -> String {
        String(format: "%.2f dl", deciliterResult)
    }
    
    // MARK: - Private Methods
    
    /// Sets up reactive bindings between properties
    private func setupBindings() {
        // Observe changes in gram amount and selected ingredient
        Publishers.CombineLatest($gramAmount, $selectedIngredient)
            .sink { [weak self] _, _ in
                self?.calculateResult()
            }
            .store(in: &cancellables)
    }
    
    /// Calculates the deciliter result based on current inputs
    private func calculateResult() {
        deciliterResult = selectedIngredient.convertGramsToDeciliters(gramAmount)
    }
}

// MARK: - Views

/// Main content view for the baking converter application
struct ContentView: View {
    @StateObject private var viewModel = BakingConverterViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
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
                                        .foregroundColor(.blue)
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
                        .foregroundColor(.orange)
                        .animation(.easeInOut, value: result)
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