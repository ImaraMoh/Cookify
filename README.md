# 🍳 Cookify – Smart Recipe Finder App

Cookify is a Flutter-based mobile application that helps users discover recipes based on available ingredients, preferences, and dietary needs.  
The app integrates the **Spoonacular API** for real-time recipe data and **Firebase** for user authentication and data storage.

---

## 🚀 Features

- 🔍 Search recipes using ingredients
- 🥗 Filter recipes by diet, meal type, and preferences
- 📖 View detailed recipe information (ingredients, steps, images)
- ❤️ Save favorite recipes
- 👤 User authentication with Firebase
- ☁️ Cloud-based data storage using Firebase Firestore
- 📱 Clean, responsive UI built with Flutter

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend Services:** Firebase
  - Firebase Authentication
  - Cloud Firestore
- **API:** Spoonacular Recipe API
- **Architecture:** REST API + Firebase Backend-as-a-Service

---

## 🧠 Project Architecture (High Level)

1. User interacts with Flutter UI
2. Flutter app sends HTTP requests to Spoonacular API
3. API returns recipe data in JSON format
4. Data is parsed into Dart models
5. User-specific data (favorites, preferences) is stored in Firebase
6. Firestore updates reflect instantly in the UI

---

## 🔐 Firebase Usage

- **Authentication:** Email & Password login
- **Firestore Database:**
  - User profiles
  - Favorite recipes
  - User preferences
- **Security:** Firestore security rules restrict data access to authenticated users only

---

## 📦 API Integration

Cookify uses the **Spoonacular API** to:
- Fetch recipes
- Get ingredients and instructions
- Retrieve nutritional and image data

API requests are handled asynchronously using `async` / `await` to ensure smooth UI performance.

---

## ⚙️ Installation & Setup

### Prerequisites
- Flutter SDK installed
- Firebase project configured
- Spoonacular API key

### Steps

1. Clone the repository
   ```bash
   git clone https://github.com/your-username/cookify.git
