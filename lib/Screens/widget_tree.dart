import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/get_started.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/Screens/start.dart';
import 'package:mobile_app/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return null; // No user data found
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data;
          return FutureBuilder(
            future: getUserData(user!.uid),
            builder: (context, AsyncSnapshot<Map<String, dynamic>?> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // Show a loading spinner while data is fetched
              } else if (userSnapshot.hasError) {
                return Center(child: Text('Error: ${userSnapshot.error}')); // Show error message if something goes wrong
              } else if (userSnapshot.hasData) {
                return HomeScreen(userData: userSnapshot.data!); // Pass user data to HomeScreen
              } else {
                return StartedScreen(); // Show GetStartedScreen if no user data is found
              }
            },
          );
        } else {
          return StartedScreen(); // Redirect to GetStartedScreen if user is not logged in
        }
      },
    );
  }
}
