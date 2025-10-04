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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // Adaptive sizing based on device
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var maxContentWidth: CGFloat {
        isIPad ? 600 : .infinity
    }
    
    private var horizontalPadding: CGFloat {
        if isIPad {
            return horizontalSizeClass == .regular ? 60 : 40
        } else {
            return 24
        }
    }
    
    private var spacing: CGFloat {
        isIPad ? 40 : 32
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                backgroundGradient
                
                GeometryReader { geometry in
                    ScrollView {
                        contentView(for: geometry.size)
                    }
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(nil) // Supports both light and dark mode
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func contentView(for size: CGSize) -> some View {
        let shouldUseGrid = isIPad && horizontalSizeClass == .regular && size.width > 768
        
        VStack(spacing: spacing) {
            headerSection
            
            if shouldUseGrid {
                // iPad landscape: Use grid layout
                iPadGridLayout
            } else {
                // iPhone and iPad portrait: Use vertical layout
                verticalLayout
            }
            
            Spacer(minLength: 20)
        }
        .frame(maxWidth: maxContentWidth)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, isIPad ? 40 : 20)
        .frame(maxWidth: .infinity) // Center content on larger screens
    }
    
    // Vertical layout for iPhone and iPad portrait
    private var verticalLayout: some View {
        VStack(spacing: spacing) {
            ingredientSelectionSection
            gramInputSection
            resultSection
        }
    }
    
    // Grid layout for iPad landscape
    private var iPadGridLayout: some View {
        VStack(spacing: spacing) {
            // First row: Ingredient selection spanning full width
            ingredientSelectionSection
            
            // Second row: Input and result side by side
            HStack(spacing: 32) {
                gramInputSection
                    .frame(maxWidth: .infinity)
                resultSection
                    .frame(maxWidth: .infinity)
            }
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
        VStack(spacing: isIPad ? 20 : 12) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: isIPad ? 72 : 48))
                .foregroundColor(.blue)
                .accessibilityHidden(true)
            
            Text("Konverter gram til desiliter for baking")
                .font(isIPad ? .title : .headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(isIPad ? 1 : 2)
        }
        .padding(.top, isIPad ? 20 : 8)
    }
    
    /// Ingredient selection section
    private var ingredientSelectionSection: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.blue)
                    .font(isIPad ? .title2 : .body)
                Text("Velg ingrediens")
                    .font(isIPad ? .title2 : .headline)
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Velg ingrediens seksjon")
            
            IngredientPickerView(
                selectedIngredient: $viewModel.selectedIngredient,
                ingredients: viewModel.ingredients,
                isIPad: isIPad
            )
        }
        .cardStyle(isIPad: isIPad)
    }
    
    /// Gram input section with slider
    private var gramInputSection: some View {
        VStack(spacing: isIPad ? 24 : 20) {
            HStack {
                Image(systemName: "scalemass")
                    .foregroundColor(.green)
                    .font(isIPad ? .title2 : .body)
                Text("Mengde i gram")
                    .font(isIPad ? .title2 : .headline)
                Spacer()
                Text(viewModel.formattedGramAmount())
                    .font(isIPad ? .title : .title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Mengde i gram: \(viewModel.formattedGramAmount())")
            
            GramSliderView(gramAmount: $viewModel.gramAmount, isIPad: isIPad)
        }
        .cardStyle(isIPad: isIPad)
    }
    
    /// Result display section
    private var resultSection: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.orange)
                    .font(isIPad ? .title2 : .body)
                Text("Resultat")
                    .font(isIPad ? .title2 : .headline)
                Spacer()
            }
            
            ResultDisplayView(
                result: viewModel.formattedDeciliterResult(),
                ingredient: viewModel.selectedIngredient.localizedName,
                isIPad: isIPad
            )
        }
        .cardStyle(isIPad: isIPad)
    }
}

/// A picker view for selecting baking ingredients
struct IngredientPickerView: View {
    @Binding var selectedIngredient: BakingIngredient
    let ingredients: [BakingIngredient]
    let isIPad: Bool
    
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
                    .font(isIPad ? .title3 : .body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(isIPad ? .body : .caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, isIPad ? 20 : 16)
            .padding(.vertical, isIPad ? 16 : 12)
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
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
    let isIPad: Bool
    
    private let minValue: Double = 1.0
    private let maxValue: Double = 1000.0
    
    var body: some View {
        VStack(spacing: isIPad ? 16 : 12) {
            // Slider
            HStack {
                Text("\(Int(minValue))")
                    .font(isIPad ? .body : .caption)
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
                .accessibilityLabel("Gram mengde glidebryter")
                .accessibilityValue("\(Int(gramAmount)) gram")
                
                Text("\(Int(maxValue))")
                    .font(isIPad ? .body : .caption)
                    .foregroundColor(.secondary)
            }
            
            // Quick selection buttons
            quickSelectionButtons
        }
    }
    
    /// Quick selection buttons for common amounts
    private var quickSelectionButtons: some View {
        HStack(spacing: isIPad ? 16 : 12) {
            ForEach([50, 100, 200, 250, 500], id: \.self) { amount in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        gramAmount = Double(amount)
                    }
                    
                    // Haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }) {
                    Text("\(amount)g")
                        .font(isIPad ? .body : .caption)
                        .fontWeight(.medium)
                        .foregroundColor(gramAmount == Double(amount) ? .white : .blue)
                        .padding(.horizontal, isIPad ? 16 : 12)
                        .padding(.vertical, isIPad ? 10 : 8)
                        .background(
                            RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                                .fill(gramAmount == Double(amount) ? Color.blue : Color.blue.opacity(0.1))
                        )
                }
                .accessibilityLabel("\(amount) gram")
                .accessibilityHint("Tipp for å velge \(amount) gram")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Hurtigvalg for gram mengder")
    }
}

/// A view that displays the conversion result with visual emphasis
struct ResultDisplayView: View {
    let result: String
    let ingredient: String
    let isIPad: Bool
    
    var body: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            // Main result display
            HStack {
                Spacer()
                
                VStack(spacing: isIPad ? 12 : 8) {
                    Text("Tilsvarer")
                        .font(isIPad ? .title3 : .subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(result)
                        .font(.system(size: isIPad ? 48 : 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .animation(.easeInOut, value: result)
                }
                
                Spacer()
            }
            .padding(.vertical, isIPad ? 32 : 20)
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                    .fill(.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                            .stroke(.orange.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Additional context
            Text("av **\(ingredient)**")
                .font(isIPad ? .body : .subheadline)
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
    func cardStyle(isIPad: Bool = false) -> some View {
        self
            .padding(isIPad ? 32 : 20)
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: isIPad ? 12 : 8, x: 0, y: isIPad ? 6 : 4)
            )
    }
}