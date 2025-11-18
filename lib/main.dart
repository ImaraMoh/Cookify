import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/animation_screen.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/Screens/login_page.dart';
import 'package:mobile_app/Screens/signUpReminderScreen.dart';
import 'package:mobile_app/Services/notification_service.dart';
import 'package:mobile_app/providers/shopping_list_provider.dart';
import 'package:provider/provider.dart';
import 'providers/saved_food_provider.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  
  NotificationService().initializeNotifications();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavedFoodProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()), // Add ThemeProvider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Recipe App',
            theme: themeProvider.currentTheme, // Apply the current theme
            home:  AnimationScreen(),
            // home: GetStartedScreen(),
            routes: {
              '/home': (context) => HomeScreen(userData: {}),
              '/signupReminder' : (context) => SignUpReminderPage(),
              '/signup' : (context) => LoginPage(),
            },
          );
        },
      ),
    );
  }
}
