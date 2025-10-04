# Bake uten vekt 🧁

A modern iOS app for converting grams to deciliters for baking ingredients. Built with SwiftUI and following iOS best practices.

## Features

- ✨ Modern SwiftUI interface with support for Dark Mode
- 🌍 Localized in English and Norwegian
- ♿ Full accessibility support with VoiceOver
- 📱 iPhone and iPad support
- 🎨 Material Design with smooth animations
- 🧪 Comprehensive unit test coverage
- 🔒 Privacy-first design (no data collection)

## Architecture

This project follows modern iOS development best practices:

### MVVM Architecture
- **Models**: `BakingIngredient` - Pure data models
- **ViewModels**: `BakingConverterViewModel` - Business logic and state management
- **Views**: SwiftUI views with clear separation of concerns

### Key Design Patterns
- **Reactive Programming**: Using Combine for state management
- **Dependency Injection**: ViewModels are injected with dependencies
- **Modular Components**: Reusable UI components
- **Accessibility First**: Full VoiceOver support and accessibility labels

### Modern iOS Features
- Swift 6.0 with strict concurrency
- iOS 17.0+ deployment target
- SwiftUI lifecycle
- Material Design system
- Haptic feedback
- Dynamic Type support

## Project Structure

```
bakeutenvekt/
├── Models/
│   └── BakingIngredient.swift
├── ViewModels/
│   └── BakingConverterViewModel.swift
├── Views/
│   ├── ContentView.swift
│   └── Components/
│       ├── IngredientPickerView.swift
│       ├── GramSliderView.swift
│       └── ResultDisplayView.swift
├── Resources/
│   ├── en.lproj/Localizable.strings
│   └── nb.lproj/Localizable.strings
└── Tests/
    ├── BakingIngredientTests.swift
    └── BakingConverterViewModelTests.swift
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

## Building and Running

1. Clone the repository
2. Open `bakeutenvekt.xcodeproj` in Xcode
3. Select your target device or simulator
4. Press Cmd+R to build and run

## Testing

Run the test suite with Cmd+U or using:

```bash
xcodebuild test -project bakeutenvekt.xcodeproj -scheme bakeutenvekt -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Original concept by Robert Petersson
- Built with ❤️ for the baking community
- Inspired by the need for accurate baking measurements

---

Made with 🇳🇴 in Norway