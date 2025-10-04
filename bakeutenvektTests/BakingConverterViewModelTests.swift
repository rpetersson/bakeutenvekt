//
//  BakingConverterViewModelTests.swift
//  bakeutenvektTests
//
//  Created by Robert Petersson on 04/10/2025.
//  Copyright © 2025 Robert Petersson. All rights reserved.
//

import XCTest
import Combine
@testable import bakeutenvekt

@MainActor
final class BakingConverterViewModelTests: XCTestCase {
    
    var viewModel: BakingConverterViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        
        // Create test ingredients
        let testIngredients = [
            BakingIngredient(name: "Test Flour", gramsPerDeciliter: 60),
            BakingIngredient(name: "Test Sugar", gramsPerDeciliter: 90)
        ]
        
        viewModel = BakingConverterViewModel(ingredients: testIngredients)
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertEqual(viewModel.gramAmount, 100.0)
        XCTAssertFalse(viewModel.ingredients.isEmpty)
        XCTAssertNotNil(viewModel.selectedIngredient)
    }
    
    func testIngredientSelection() {
        // Given
        let newIngredient = viewModel.ingredients.last!
        
        // When
        viewModel.selectIngredient(newIngredient)
        
        // Then
        XCTAssertEqual(viewModel.selectedIngredient.id, newIngredient.id)
    }
    
    func testGramAmountUpdate() {
        // Given
        let newAmount: Double = 250.0
        
        // When
        viewModel.updateGramAmount(newAmount)
        
        // Then
        XCTAssertEqual(viewModel.gramAmount, newAmount)
    }
    
    func testNegativeGramAmountHandling() {
        // Given
        let negativeAmount: Double = -50.0
        
        // When
        viewModel.updateGramAmount(negativeAmount)
        
        // Then
        XCTAssertEqual(viewModel.gramAmount, 0.0)
    }
    
    func testResultCalculation() {
        // Given
        let flour = BakingIngredient(name: "Test Flour", gramsPerDeciliter: 60)
        viewModel.selectIngredient(flour)
        viewModel.updateGramAmount(120.0)
        
        // Wait for calculation
        let expectation = XCTestExpectation(description: "Result calculation")
        
        viewModel.$deciliterResult
            .dropFirst() // Skip initial value
            .sink { result in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When - trigger calculation by updating amount
        viewModel.updateGramAmount(120.0)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.deciliterResult, 2.0, accuracy: 0.001)
    }
    
    func testFormattedGramAmount() {
        // Given
        viewModel.updateGramAmount(150.0)
        
        // When
        let formatted = viewModel.formattedGramAmount()
        
        // Then
        XCTAssertEqual(formatted, "150 g")
    }
    
    func testFormattedDeciliterResult() {
        // Given
        viewModel.updateGramAmount(90.0) // Should give 1.5 dl with 60g/dl ingredient
        
        // When
        let formatted = viewModel.formattedDeciliterResult()
        
        // Then
        XCTAssertTrue(formatted.contains("dl"))
        XCTAssertTrue(formatted.contains("1.50"))
    }
    
    func testIngredientsSorting() {
        // Given
        let unsortedIngredients = [
            BakingIngredient(name: "Zebra", gramsPerDeciliter: 60),
            BakingIngredient(name: "Apple", gramsPerDeciliter: 90),
            BakingIngredient(name: "Banana", gramsPerDeciliter: 75)
        ]
        
        // When
        let sortedViewModel = BakingConverterViewModel(ingredients: unsortedIngredients)
        
        // Then
        let names = sortedViewModel.ingredients.map { $0.localizedName }
        let sortedNames = names.sorted()
        XCTAssertEqual(names, sortedNames)
    }
}