# DripLix 📌

A picture feed app like Pinterest - cross-platform for iOS, web, and Android built with Flutter.

## Features

- **Visual Discovery**: Explore trending and popular visual content
- **Save & Organize**: Bookmark your favorite images in organized boards
- **Create & Share**: Share your own visual content and boards
- **Cross-Platform**: Available on iOS, Android, and Web

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- For web development: Chrome browser

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd DripLix
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web
flutter run -d chrome

# For mobile (with device connected)
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   └── home_screen.dart     # Home screen implementation
└── widgets/
    ├── navigation_bar.dart  # Custom navigation bar
    └── project_description.dart # Project description widget

assets/
└── images/
    ├── logos/               # App logos and branding
    ├── navigation/          # Navigation bar icons
    └── icons/              # General app icons
```

## Design Theme

The app uses a clean **black and white** color scheme:
- **Primary**: Black (#000000)
- **Secondary**: White (#FFFFFF) 
- **Accent**: Various shades of gray
- **Background**: Pure white
- **Text**: Black with varying opacity levels

## Adding Custom Images

To add your own logos and icons:

1. **App Logo**: Place your logo in `assets/images/logos/`
   - `app_logo_small.png` (64x64px) - Navigation bar logo
   - `app_logo.png` (512x512px) - Full app logo

2. **Navigation Icons**: Place icons in `assets/images/navigation/`
   - `search_icon.png` (24x24px)
   - `notification_icon.png` (24x24px)
   - `profile_icon.png` (20x20px)

3. **Feature Icons**: Place icons in `assets/images/icons/`
   - `explore_icon.png` (40x40px)
   - `save_icon.png` (40x40px)
   - `share_icon.png` (40x40px)

**Image Requirements:**
- Format: PNG with transparency
- Style: Black and white theme
- High resolution for retina displays
- Transparent background preferred

## Web Development

The web version is currently in development. To run on web:

```bash
flutter run -d chrome
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
