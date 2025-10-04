//
//  BakingIngredientTests.swift
//  bakeutenvektTests
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import XCTest
@testable import bakeutenvekt

final class BakingIngredientTests: XCTestCase {
    
    func testIngredientInitialization() {
        // Given
        let name = "Test Flour"
        let gramsPerDL = 60
        
        // When
        let ingredient = BakingIngredient(name: name, gramsPerDeciliter: gramsPerDL)
        
        // Then
        XCTAssertEqual(ingredient.name, name)
        XCTAssertEqual(ingredient.gramsPerDeciliter, gramsPerDL)
        XCTAssertNotNil(ingredient.id)
    }
    
    func testGramsToDecilitersConversion() {
        // Given
        let ingredient = BakingIngredient(name: "Flour", gramsPerDeciliter: 60)
        let grams: Double = 120
        
        // When
        let result = ingredient.convertGramsToDeciliters(grams)
        
        // Then
        XCTAssertEqual(result, 2.0, accuracy: 0.001)
    }
    
    func testDecilitersToGramsConversion() {
        // Given
        let ingredient = BakingIngredient(name: "Sugar", gramsPerDeciliter: 90)
        let deciliters: Double = 1.5
        
        // When
        let result = ingredient.convertDecilitersToGrams(deciliters)
        
        // Then
        XCTAssertEqual(result, 135.0, accuracy: 0.001)
    }
    
    func testZeroGramsPerDeciliterHandling() {
        // Given
        let ingredient = BakingIngredient(name: "Invalid", gramsPerDeciliter: 0)
        let grams: Double = 100
        
        // When
        let result = ingredient.convertGramsToDeciliters(grams)
        
        // Then
        XCTAssertEqual(result, 0.0)
    }
    
    func testDefaultIngredientsNotEmpty() {
        // When
        let ingredients = BakingIngredient.defaultIngredients
        
        // Then
        XCTAssertFalse(ingredients.isEmpty)
        XCTAssertGreaterThan(ingredients.count, 10)
    }
    
    func testIngredientEquality() {
        // Given
        let ingredient1 = BakingIngredient(name: "Flour", gramsPerDeciliter: 60)
        let ingredient2 = BakingIngredient(name: "Flour", gramsPerDeciliter: 60)
        
        // Then
        XCTAssertNotEqual(ingredient1, ingredient2) // Different IDs
        XCTAssertEqual(ingredient1.name, ingredient2.name)
        XCTAssertEqual(ingredient1.gramsPerDeciliter, ingredient2.gramsPerDeciliter)
    }
    
    func testIngredientCodable() throws {
        // Given
        let ingredient = BakingIngredient(name: "Test Ingredient", gramsPerDeciliter: 75)
        
        // When
        let encoded = try JSONEncoder().encode(ingredient)
        let decoded = try JSONDecoder().decode(BakingIngredient.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.name, ingredient.name)
        XCTAssertEqual(decoded.gramsPerDeciliter, ingredient.gramsPerDeciliter)
    }
}