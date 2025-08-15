# BusinessHub Mobile

A modern Flutter mobile application for business management and growth.

## 🚀 Features

- **Modern UI/UX**: Glassmorphism design with gradient backgrounds
- **User Authentication**: Registration and login functionality
- **Form Validation**: Comprehensive input validation
- **Responsive Design**: Works across different screen sizes
- **Material Design 3**: Latest Material Design principles

## 📱 Screens

### Authentication
- **Register Screen**: User registration with form validation
- **Login Screen**: User authentication
- **Email Verification**: Email verification flow

### Components
- **Custom Cards**: Reusable card components with modern styling
- **App Bar**: Custom app bar with search and notifications
- **Form Fields**: Styled text fields with validation

## 🛠️ Project Structure

```
lib/
├── flutter_flow/           # FlutterFlow utilities
│   ├── auth_manager.dart   # Authentication management
│   ├── flutter_flow_theme.dart
│   ├── flutter_flow_util.dart
│   └── flutter_flow_widgets.dart
├── userManagement/         # Authentication screens
│   ├── login.dart
│   ├── login_model.dart
│   ├── register.dart
│   ├── register_model.dart
│   └── verify_email.dart
├── model/                  # State management models
│   ├── appBar_model.dart
│   ├── appBarMobile_model.dart
│   ├── card2Model1.dart
│   ├── createModel.dart
│   ├── drawer_model.dart
│   ├── menuMobileModel.dart
│   └── saiderbar_model.dart
├── cards/                  # Card components
│   └── cardWidget.dart
├── componets/              # UI components
│   ├── card2/
│   ├── cardfood/
│   ├── component_desktop/
│   ├── menu_mobile/
│   └── saider_bar/
├── business_hub/           # Business logic components
│   ├── app_bar/
│   ├── app_bar_mobile/
│   └── drawer/
├── home_model.dart         # Home screen model
└── main.dart              # App entry point
```

## 🎨 Design System

### Colors
- **Primary**: `#667eea` (Purple gradient)
- **Secondary**: `#764ba2` (Purple gradient)
- **Background**: White with glassmorphism effects
- **Text**: White on gradient backgrounds

### Typography
- **Title**: 28px, Bold
- **Body**: 16px, Regular
- **Caption**: 14px, Regular

### Components
- **Glassmorphism**: Translucent containers with blur effects
- **Gradient Backgrounds**: Purple gradient themes
- **Rounded Corners**: 12px border radius
- **Shadows**: Subtle elevation effects

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  provider: ^6.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd BusinessHub-Mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Development

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting

### State Management
- Use models for state management
- Implement proper dispose methods
- Follow FlutterFlow patterns

### UI/UX Guidelines
- Maintain glassmorphism design consistency
- Use gradient backgrounds appropriately
- Ensure proper contrast ratios
- Test on different screen sizes

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For support and questions, please contact the development team.

---

**Built with ❤️ using Flutter** 
