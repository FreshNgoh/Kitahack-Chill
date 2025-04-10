## 🍽️ EatMeh – AI-Powered Calorie Tracking with Friends

EatMeh is a mobile application designed to help users effortlessly track their daily calorie intake using AI-powered food scanning while staying connected with friends for support and motivation. Built with Flutter and integrated with Gemini AI and Firebase, EatMeh promotes healthier eating habits and social accountability, making nutrition tracking easier, smarter, and more engaging.

🧠 What Can EatMeh Do?

1. 📷 Scan Your Meals – Use your phone’s camera to scan your food. Gemini AI will automatically recognize the ingredients and estimate the calorie content.

2. 🧾 Track Calorie Intake – Easily view and manage your daily food records with real-time calorie information.

3. 👯 Connect With Friends – Add friends, share your food logs, and supervise each other’s progress toward healthier lifestyles.

4. 📝 View Records – Access a history of your food intake to monitor long-term eating patterns.

## 🧑‍💻 Getting Started

1. Running `flutter pub get` and `flutter packages get` in terminal
2. Add Your Gemini API and Firebase Credentials under libs/utils, refer to to constant_example.dart and firebase_option_example.dart

TO DO SO

```
cd libs/utils
touch constant.dart
touch firebase_option.dart
```

TO ADD FIREBASE CREDENTIALS

a.Install firebase-tools cli globally

```
npm install -g firebase-tools
```

b.Install flutterfire cli

```
dart pub global activate flutterfire_cli
```

c. Configure the firebase credentails

```
flutterfire configure
```

More configuration can refer [https://firebase.flutter.dev/docs/cli/]

3. Select your prefer simulator (Andriod, iOS)
4. Run the app on **main.dart**

   - Mac: `command` + `shit` + `F5`
   - Andriod: `F5`

   OR

   ```
   flutter run --debug
   ```

## 📁 Project File Structure

`lib/bloc/` – Contains the BLoC (Business Logic Component) files for state management. This helps in separating UI from business logic, making the app reactive and testable.

`lib/components/` – Reusable UI widgets or components such as buttons, cards, and custom layouts used across the app.

`lib/models/` – Includes data model classes that represent and structure the data used in the app, such as user model or chat model.

`lib/pages/` – Screens and views of the app. Each file represents a different page, like Home, Profile, or Friends page.

`lib/repos/` – Short for repositories. This folder handles data logic and acts as a bridge between services and the UI, managing how data is fetched or saved.

`lib/services/` – Contains service classes like API integrations, AI scanning logic (Gemini), or Firebase interactions.

`lib/main.dart` – The entry point of the app. This is where the app starts and is configured, including theme, routes, and initializations.

## Pubspec.yaml

1. To add new packages, start from `line 29: dependencies`
2. To add assests to this application, add an assests section start from `line 84: assests`
3. To add custom fonts to this application, add a fonts section start from `line 100: fonts`
