# TVQuizMaster - A Modern tvOS Quiz App

TVQuizMaster is a feature-rich quiz application designed specifically for Apple TV, built with SwiftUI. It offers an engaging quiz experience with smooth animations, focus management, and a clean, intuitive interface.

## Features

- 🎮 **tvOS Optimized**: Built specifically for the big screen with focus management and Siri Remote support
- 🏆 **Multiple Categories**: Choose from various quiz categories
- 📊 **Track Progress**: View your score and progress in real-time
- 🎨 **Beautiful Animations**: Smooth transitions and focus effects
- 🎮 **Game Controller Support**: Play with your favorite game controller
- ♿ **Accessibility**: Full support for VoiceOver and other accessibility features
- 💾 **Persistence**: High scores are saved between sessions

## Requirements

- Xcode 15.0+
- tvOS 16.0+
- Swift 5.9+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/TVQuizMaster.git
   ```
2. Open `TVQuizMaster.xcodeproj` in Xcode
3. Build and run the project on the tvOS simulator or a physical Apple TV device

## Project Structure

```
TVQuizMaster/
├── TVQuizMaster/
│   ├── Models/           # Data models and structures
│   ├── ViewModels/       # Business logic and data handling
│   ├── Views/            # SwiftUI views
│   ├── Resources/        # Assets, colors, and other resources
│   └── TVQuizMasterApp.swift # App entry point
└── TVQuizMasterTests/    # Unit tests
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Define the data structure and business logic
- **ViewModels**: Handle the presentation logic and state management
- **Views**: Present the UI and handle user interactions

## Adding Questions

Questions are loaded from a local JSON file. To add or modify questions, edit the `questions.json` file in the Resources folder.

## Testing

Run tests using `Cmd+U` in Xcode or through the Test navigator.

## Contributing

Contributions are welcome! Please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
