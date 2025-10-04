import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BakingWatchViewModel()
    @State private var showingIngredientPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                // Header
                Text("Bake uten vekt")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.bottom, 4)
                
                // Selected ingredient
                Button(action: {
                    showingIngredientPicker = true
                }) {
                    VStack(spacing: 2) {
                        Text("Ingrediens")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.selectedIngredient.norwegianName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Weight input
                VStack(spacing: 2) {
                    Text("Vekt (gram)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("-") {
                            viewModel.decrementWeight()
                        }
                        .font(.title2)
                        .frame(width: 30, height: 30)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(6)
                        
                        Text("\(viewModel.weightInGrams, specifier: "%.0f")g")
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(minWidth: 60)
                        
                        Button("+") {
                            viewModel.incrementWeight()
                        }
                        .font(.title2)
                        .frame(width: 30, height: 30)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(6)
                    }
                }
                .padding(.vertical, 4)
                
                // Result
                VStack(spacing: 2) {
                    Text("Resultat")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.resultText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                        .frame(minHeight: 30)
                }
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingIngredientPicker) {
            IngredientPickerView(viewModel: viewModel)
        }
    }
}

struct IngredientPickerView: View {
    @ObservedObject var viewModel: BakingWatchViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.availableIngredients, id: \.englishName) { ingredient in
                    Button(action: {
                        viewModel.selectedIngredient = ingredient
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(ingredient.norwegianName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(ingredient.englishName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if viewModel.selectedIngredient.englishName == ingredient.englishName {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Velg ingrediens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ferdig") {
                        dismiss()
                    }
                    .font(.caption)
                }
            }
        }
    }
}

// Watch-specific ViewModel
class BakingWatchViewModel: ObservableObject {
    @Published var selectedIngredient: Ingredient
    @Published var weightInGrams: Double = 50.0
    
    let availableIngredients: [Ingredient] = [
        Ingredient(englishName: "Egg", norwegianName: "Egg", measurements: [
            Measurement(unit: "stort egg", gramsPerUnit: 60),
            Measurement(unit: "middels egg", gramsPerUnit: 50),
            Measurement(unit: "lite egg", gramsPerUnit: 40)
        ]),
        Ingredient(englishName: "Butter", norwegianName: "Smør", measurements: [
            Measurement(unit: "ss", gramsPerUnit: 15),
            Measurement(unit: "ts", gramsPerUnit: 5),
            Measurement(unit: "dl", gramsPerUnit: 80)
        ]),
        Ingredient(englishName: "Sugar", norwegianName: "Sukker", measurements: [
            Measurement(unit: "dl", gramsPerUnit: 85),
            Measurement(unit: "ss", gramsPerUnit: 13),
            Measurement(unit: "ts", gramsPerUnit: 4)
        ]),
        Ingredient(englishName: "Flour", norwegianName: "Mel", measurements: [
            Measurement(unit: "dl", gramsPerUnit: 60),
            Measurement(unit: "ss", gramsPerUnit: 9),
            Measurement(unit: "ts", gramsPerUnit: 3)
        ]),
        Ingredient(englishName: "Milk", norwegianName: "Melk", measurements: [
            Measurement(unit: "dl", gramsPerUnit: 100),
            Measurement(unit: "ss", gramsPerUnit: 15),
            Measurement(unit: "ts", gramsPerUnit: 5)
        ])
    ]
    
    init() {
        self.selectedIngredient = availableIngredients[0]
    }
    
    var resultText: String {
        let conversions = selectedIngredient.measurements.compactMap { measurement -> String? in
            let quantity = weightInGrams / measurement.gramsPerUnit
            if quantity >= 0.1 {
                return String(format: "%.1f %@", quantity, measurement.unit)
            }
            return nil
        }
        
        if conversions.isEmpty {
            return "For lite mengde"
        } else if conversions.count == 1 {
            return conversions[0]
        } else {
            return conversions.prefix(2).joined(separator: "\n")
        }
    }
    
    func incrementWeight() {
        if weightInGrams < 10 {
            weightInGrams += 1
        } else if weightInGrams < 50 {
            weightInGrams += 5
        } else if weightInGrams < 200 {
            weightInGrams += 10
        } else {
            weightInGrams += 25
        }
        
        if weightInGrams > 1000 {
            weightInGrams = 1000
        }
    }
    
    func decrementWeight() {
        if weightInGrams <= 10 {
            weightInGrams = max(1, weightInGrams - 1)
        } else if weightInGrams <= 50 {
            weightInGrams -= 5
        } else if weightInGrams <= 200 {
            weightInGrams -= 10
        } else {
            weightInGrams -= 25
        }
        
        if weightInGrams < 1 {
            weightInGrams = 1
        }
    }
}

// Shared data models (simplified for watch)
struct Ingredient {
    let englishName: String
    let norwegianName: String
    let measurements: [Measurement]
}

struct Measurement {
    let unit: String
    let gramsPerUnit: Double
}

#Preview {
    ContentView()
}