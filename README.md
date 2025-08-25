# Questly 🎯

> A bucket list & life goals Flutter app with Supabase backend

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Authentication-FFCA28?style=flat&logo=firebase)](https://firebase.google.com)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=flat&logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 📱 About

Questly is a modern, cross-platform mobile application designed to help users create, manage, and track their bucket lists and life goals. Built with Flutter and powered by Firebase authentication and Supabase backend, Questly provides a seamless experience for organizing your dreams and aspirations.

## ✨ Features

### 🔐 Authentication
- **Google Sign-In Integration** - Secure authentication via Firebase Auth
- **User Profile Management** - Personalized user profiles with photo support
- **Cross-platform Sessions** - Seamless login across all devices

### 📋 Lists Management
- **Create Custom Lists** - Organize goals into themed bucket lists
- **Color-coded Categories** - Visual organization with custom colors
- **Progress Tracking** - Real-time completion statistics
- **Pull-to-refresh** - Stay updated with latest changes

### 🎯 Goals Tracking
- **Goal Creation & Management** - Add, edit, and organize your life goals
- **Status Tracking** - Mark goals as pending, in-progress, or completed
- **Progress Visualization** - Visual progress indicators and completion percentages
- **Goal Details** - Rich descriptions and metadata for each goal

### 🎨 User Experience
- **Material Design 3** - Modern, intuitive interface
- **Dark/Light Theme Support** - Adaptive theming
- **Responsive Design** - Optimized for phones and tablets
- **Smooth Animations** - Polished user interactions

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.8.1+** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material Design 3** - UI/UX design system

### Backend & Services
- **Supabase** - Backend-as-a-Service (Database, Real-time subscriptions)
- **Firebase Auth** - Authentication service
- **Google Sign-In** - OAuth integration

### Key Dependencies
```yaml
supabase_flutter: ^2.8.0      # Supabase client
firebase_core: ^3.6.0         # Firebase core
firebase_auth: ^5.3.1         # Firebase authentication
google_sign_in: ^6.2.1        # Google OAuth
go_router: ^14.6.2            # Navigation
flutter_dotenv: ^5.2.1        # Environment variables
equatable: ^2.0.5             # Value equality
json_annotation: ^4.9.0       # JSON serialization
```

## 📁 Project Structure
lib/
├── app.dart                    # Main app configuration
├── bootstrap.dart              # App initialization
├── main.dart                   # Entry point
├── config/
│   └── theme.dart             # App theming
├── core/
│   ├── router.dart            # Navigation configuration
│   └── widgets/               # Reusable widgets
├── data/
│   ├── models/                # Data models
│   └── repositories/          # Data repositories
├── features/
│   ├── auth/                  # Authentication screens
│   ├── goals/                 # Goals management
│   ├── lists/                 # Lists management
│   └── splash/                # Splash screen
├── services/
│   ├── firebase_auth_service.dart  # Firebase auth service
│   └── supabase_client.dart       # Supabase client
└── firebase_options.dart      # Firebase configuration



## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Firebase](https://firebase.google.com) - Authentication
- [Supabase](https://supabase.com) - Backend services
- [Material Design](https://material.io) - Design system

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Contact the development team

---

Made with ❤️ using Flutter
