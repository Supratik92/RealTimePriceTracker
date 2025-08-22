# Real-Time Stock Price Tracker

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-orange.svg)
![Swift](https://img.shields.io/badge/Swift-5.7+-red.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A real-time stock price tracking iOS app built with SwiftUI that demonstrates advanced iOS development patterns including MVVM+C architecture, WebSocket integration, and comprehensive testing.

## 🚀 Features

### Core Functionality
- **Real-time Price Updates**: Live tracking of 25 major stock symbols with 2-second refresh intervals
- **WebSocket Integration**: Connects to Postman Echo WebSocket service for real-time data simulation
- **Sortable Price Feed**: Dynamic list sorted by current price (highest to lowest)
- **Symbol Details**: Dedicated detail screen for each stock symbol
- **Connection Management**: Visual connection status indicator and manual start/stop controls

### Advanced Features
- **Visual Feedback**: Green ↑/Red ↓ price change indicators with optional flash animations
- **Deep Linking**: Custom URL scheme `stocks://symbol/{SYMBOL}` for direct navigation
- **Accessibility**: Full VoiceOver support, Dynamic Type, and semantic labels
- **Localization**: Multi-language support with externalized strings
- **Theme Support**: Adaptive light/dark mode following system preferences

## 📱 Screenshots

| Feed Screen | Symbol Details | Dark Mode |
|-------------|----------------|-----------|
| *Coming Soon* | *Coming Soon* | *Coming Soon* |

## 🏗️ Architecture

### MVVM+C Pattern
This app implements the **Model-View-ViewModel + Coordinator** pattern for clean separation of concerns:

```
├── Models/
│   ├── StockSymbol.swift          # Core data models
│   └── PriceUpdate.swift
├── ViewModels/
│   ├── StockFeedViewModel.swift   # Business logic & state management
│   └── SymbolDetailViewModel.swift
├── Views/
│   ├── StockFeedView.swift        # SwiftUI views
│   ├── SymbolDetailView.swift
│   └── Components/
├── Coordinators/
│   └── AppCoordinator.swift       # Navigation logic
├── Services/
│   ├── WebSocketService.swift     # WebSocket communication
│   └── PriceGeneratorService.swift
└── Utilities/
    ├── DeepLinkHandler.swift      # URL scheme handling
    └── ThemeManager.swift
```

### Key Components

#### WebSocketService
- Manages connection to `wss://ws.postman-echo.com/raw`
- Handles automatic reconnection and error recovery
- Uses Combine publishers for reactive data flow

#### StockFeedViewModel
- Manages state for 25 stock symbols
- Orchestrates price updates every 2 seconds
- Implements sorting logic (highest price first)
- Publishes UI state changes via Combine

#### AppCoordinator
- Handles navigation between feed and detail screens
- Manages deep link routing
- Maintains navigation state

## 🛠️ Technical Implementation

### State Management
- **@StateObject**: For ViewModels at screen level
- **@ObservedObject**: For passed ViewModels
- **@EnvironmentObject**: For shared services (WebSocketService)
- **@State**: For local UI state

### Reactive Programming
- **Combine Framework**: WebSocket data streams and UI updates
- **Publishers**: Price updates, connection status, navigation events
- **Subscribers**: UI components react to state changes

### WebSocket Protocol
```swift
// Message format sent every 2 seconds per symbol
{
  "symbol": "AAPL",
  "price": 185.47,
  "timestamp": "2025-08-22T10:30:00Z"
}
```

## 📦 Dependencies

### Native Frameworks
- **SwiftUI**: UI framework
- **Combine**: Reactive programming
- **Foundation**: Core utilities
- **Network**: Connection monitoring

### No External Dependencies
This project uses only native iOS frameworks to demonstrate pure SwiftUI and Combine capabilities.

## 🎯 Installation & Setup

### Prerequisites
- Xcode 15.0+
- iOS 15.0+ deployment target
- macOS 13.0+ for development

### Quick Start
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/stock-price-tracker.git
   cd stock-price-tracker
   ```

2. **Open in Xcode**
   ```bash
   open StockTracker.xcodeproj
   ```

3. **Build and run**
   - Select your target device/simulator
   - Press `Cmd+R` to build and run

### Deep Link Testing
Test deep linking functionality:
```bash
xcrun simctl openurl booted "stocks://symbol/AAPL"
```

## 🧪 Testing

### Test Coverage
- **Unit Tests**: Business logic, ViewModels, Services (90%+ coverage target)
- **UI Tests**: User interaction flows, navigation, accessibility
- **Integration Tests**: WebSocket connectivity, data flow

### Running Tests
```bash
# Unit tests
xcodebuild test -scheme StockTracker -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme StockTrackerUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Structure
```
Tests/
├── UnitTests/
│   ├── ViewModelTests/
│   ├── ServiceTests/
│   └── ModelTests/
└── UITests/
    ├── FeedScreenTests.swift
    ├── DetailScreenTests.swift
    └── NavigationTests.swift
```

## ♿ Accessibility

### VoiceOver Support
- Semantic labels for all interactive elements
- Custom accessibility actions for price updates
- Proper reading order and focus management

### Dynamic Type
- Supports all text size categories
- Scalable UI layout that adapts to user preferences
- Custom font scaling for price displays

### Accessibility Features
- High contrast mode support
- Reduce motion animations respect user preferences
- Voice Control compatibility

## 🌍 Localization

### Supported Languages
- English (Base)
- Spanish (es)
- French (fr)
- German (de)
- Japanese (ja)

### Localization Implementation
- `Localizable.strings` files for each language
- Programmatic string localization using `NSLocalizedString`
- Number and currency formatting based on locale

## 🎨 Theming

### Theme Support
- **Light Mode**: Clean, professional appearance
- **Dark Mode**: OLED-friendly dark theme
- **System Integration**: Automatic theme switching
- **Custom Colors**: Semantic color system that adapts to themes

### Color Palette
```swift
// Semantic colors that adapt to light/dark mode
Color.primary      // Text colors
Color.secondary    // Secondary text
Color.accentColor  // Interactive elements
Color.green       // Price increases
Color.red         // Price decreases
```

## 📊 Performance

### Optimization Strategies
- **Lazy Loading**: LazyVStack for efficient list rendering
- **Debounced Updates**: Prevents excessive UI refreshes
- **Memory Management**: Proper Combine subscription lifecycle
- **Background Processing**: Price calculations on background queue

### Performance Metrics
- **Launch Time**: < 2 seconds cold start
- **Memory Usage**: < 50MB typical usage
- **Battery Impact**: Optimized WebSocket usage

## 🔧 Configuration

### Build Configurations
- **Debug**: Full logging, debug symbols
- **Release**: Optimized performance, minimal logging

### Environment Setup
```swift
// Configuration.swift
enum Environment {
    case development
    case production
    
    var webSocketURL: String {
        return "wss://ws.postman-echo.com/raw"
    }
}
```

## 📈 Project Structure

```
StockTracker/
├── App/
│   ├── StockTrackerApp.swift      # App entry point
│   └── AppCoordinator.swift       # Main coordinator
├── Features/
│   ├── Feed/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   └── SymbolDetail/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Core/
│   ├── Services/
│   ├── Utilities/
│   └── Extensions/
├── Resources/
│   ├── Localizable.strings
│   ├── Assets.xcassets
│   └── Info.plist
└── Tests/
    ├── UnitTests/
    └── UITests/
```

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- SwiftLint configuration for consistent formatting
- 100% Swift code coverage for critical paths
- Comprehensive documentation for public APIs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Postman Echo**: WebSocket testing service
- **Apple**: SwiftUI and Combine frameworks
- **Community**: iOS development best practices and patterns

## 📞 Support

For questions, issues, or contributions:
- Create an issue in this repository
- Review the documentation
- Check existing discussions

---

**Built with ❤️ using SwiftUI and modern iOS development practices**
