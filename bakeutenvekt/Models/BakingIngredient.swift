//
//  BakingIngredient.swift
//  bakeutenvekt
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import Foundation

/// Represents a baking ingredient with its name and density
struct BakingIngredient: Hashable, Identifiable, Codable {
    let id = UUID()
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
}

// MARK: - Predefined Ingredients
extension BakingIngredient {
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