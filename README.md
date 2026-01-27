# 🍎 Smart Grocery List

Smart Grocery List is a modern, AI-powered Flutter application designed to make grocery shopping effortless and organized. It combines the power of machine learning for real-time item predictions with a sleek, premium UI for a superior user experience.

![App Icon](smartgrocerylist/assets/app_icon.png) <!-- Ensure you have an icon path or remove this -->

## 🚀 Key Features

### 🤖 AI-Powered Intelligence
- **Real-time Predictions**: The app learns your shopping habits and suggests items based on the time of day, day of the week (e.g., "morning" vs "weekend"), and your previous patterns.
- **Smart Categorization**: Automatically sorts items into logical groups like *Produce*, *Dairy*, *Bakery*, and *Meat*, making your trip through the store much faster.
- **Contextual Suggestions**: Predicts what you need before you even finish typing.

### 🔄 Seamless Sync & Cloud
- **Real-time Synchronization**: Powered by **Supabase**, your lists are instantly synced across all your devices.
- **Secure Authentication**: Easy and secure login using **Email Magic Links** (OTP-free experience).
- **Infinite Undo/Trash**: ACCIDENTALLY deleted a list? Restore it easily from the built-in Trash system.

### 🎨 Premium User Experience
- **Elegant UI/UX**: Built with a "wow" factor in mind, featuring smooth transitions and a modern aesthetic.
- **Dark & Light Mode**: Seamlessly switch between themes based on your preference.
- **Cross-Platform**: Fully compatible with Android and iOS.

### 💳 Pro Features
- **Integrated Payments**: Ready for a premium experience with secure **PayPal** integration.
- **No Ads**: Focused shopping without interruptions.

## 🛠️ Tech Stack

- **Frontend**: Flutter & GetX (State Management)
- **Backend/Auth**: Supabase
- **Local Database**: SQLite (for offline capabilities)
- **Intelligence**: Custom ML behavior prediction model
- **Environment**: Flutter Dotenv for secure configuration

## 📦 Getting Started

### Prerequisites
- Flutter SDK (latest version)
- A Supabase project

### Setup
1. Clone the repository.
2. Create a `.env` file in the `smartgrocerylist` directory.
3. Add your Supabase credentials:
   ```env
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```
4. Run `flutter pub get`.
5. Run the app using `flutter run`.

## 📄 License
Taha - 2026
