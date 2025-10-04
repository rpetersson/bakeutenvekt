//
//  BakingConverterViewModel.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import Foundation
import Combine

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
        self.ingredients = ingredients.sorted { $0.localizedName < $1.localizedName }
        self.selectedIngredient = self.ingredients.first ?? BakingIngredient(name: "Unknown", gramsPerDeciliter: 60)
        
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

// MARK: - Error Handling
extension BakingConverterViewModel {
    enum ConversionError: LocalizedError {
        case invalidIngredient
        case invalidAmount
        
        var errorDescription: String? {
            switch self {
            case .invalidIngredient:
                return NSLocalizedString("error.invalid_ingredient", 
                                       value: "Invalid ingredient selected", 
                                       comment: "Error when ingredient is invalid")
            case .invalidAmount:
                return NSLocalizedString("error.invalid_amount", 
                                       value: "Invalid amount entered", 
                                       comment: "Error when amount is invalid")
            }
        }
    }
}