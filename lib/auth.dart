import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/otp_verification_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  

  // Get the current user's ID
  String? getCurrentUserId() {
    return currentUser?.uid;
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Save user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

    } catch (e) {
      if (kDebugMode) {
        print('Error during sign-up: $e');
      }
      throw Exception('Sign-up failed. Please try again.');
    }
  }

  // Create new user with email, password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Generate and send OTP
      final otp = generateOTP();
      await saveOTPToFirestore(userId, otp);
      await sendEmail(email, otp);

      // Update the user's display name in Firebase Authentication
      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(userId: userId, email: 'email', otp: 'otp'),
        ),
      );

      // Send email verification
      //await userCredential.user!.sendEmailVerification();

      // Save additional user data to Firestore including phone number
      await _saveUserData(userCredential.user!, name);

      if (kDebugMode) {
        print("User created and data saved successfully. Verification email sent.");
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user: $e");
      }
      throw Exception("User creation failed: $e");
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': name,  // Save the phone number to Firestore
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Initialize subcollections
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('recently_viewed')
          .doc('initial_document')
          .set({
        'initialized': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print("User data saved and subcollections initialized.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving user data: $e");
      }
      throw Exception("Failed to save user data to Firestore: $e");
    }
  }

  Future<void> sendEmail(String email, String otp) async {
    // SMTP Server Configuration (e.g., Gmail SMTP)
    final smtpServer = gmail('cookifyrecipes1234@gmail.com', 'ottk glee trub cgqv');

    // Create the email message
    final message = Message()
      ..from = Address('cookifyrecipes1234@gmail.com', 'Cookify Team')
      ..recipients.add(email) // Recipient's email
      ..subject = 'Your OTP Code for Cookify App'
      ..text = 'Hello,\n\nYour OTP code is: $otp\n\nPlease use this code to verify your email address. '
              'This code is valid for 5 minutes.\n\nThanks,\nCookify Team';

    try {
      final sendReport = await send(message, smtpServer);
      if (kDebugMode) {
        print('Message sent: ${sendReport.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Message not sent. Error: $e');
      }
      throw Exception('Failed to send email. Please try again.');
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String userId, String enteredOTP) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('User not found or invalid userId.');
      }

      final storedOTP = doc['otp'];
      final expirationTime = (doc['otpExpiration'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expirationTime)) {
        throw Exception('OTP has expired. Please request a new one.');
      }

      final attempts = doc['otpAttempts'] ?? 0;

      if (attempts >= 5) {
        throw Exception('Too many incorrect attempts. Please request a new OTP.');
      }

      if (storedOTP != enteredOTP) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'otpAttempts': attempts + 1,
        });
        return false;
      }

      // Reset attempts and delete OTP
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'otpAttempts': 0,
        'otp': FieldValue.delete(),
        'otpExpiration': FieldValue.delete(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying OTP: $e');
      }
      throw Exception('Failed to verify OTP. Please try again.');
    }
  }

  Future<void> saveOTPToFirestore(String userId, String otp) async {
    final expirationTime = DateTime.now().add(const Duration(minutes: 5)); // OTP valid for 5 minutes

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'otp': otp,
      'otpExpiration': expirationTime,
      'otpAttempts': 0, // Reset attempts when a new OTP is generated
    });
  }

  Future<void> resendOTP(String userId, String email) async {
    final newOTP = generateOTP();
    await saveOTPToFirestore(userId, newOTP);
    await sendEmail(email, newOTP);
  }

  String generateOTP() {
    final random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  Future<void> cleanExpiredOTPs() async {
    final now = DateTime.now();
    final users = await FirebaseFirestore.instance.collection('users').get();

    for (var user in users.docs) {
      final expirationTime = (user['otpExpiration'] as Timestamp).toDate();
      if (now.isAfter(expirationTime)) {
        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
          'otp': FieldValue.delete(),
          'otpExpiration': FieldValue.delete(),
          'otpAttempts': 0,
        });
      }
    }
  }


  // Save recently viewed recipe to the user's subcollection
  Future<void> saveRecentlyViewedRecipe(String recipeId, String title, String image) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('recently_viewed')
          .doc(recipeId)
          .set({
        'recipeId': recipeId,
        'title': title,
        'image': image,
        'viewedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print("Recipe saved to 'recently_viewed' successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving recently viewed recipe: $e");
      }
      throw Exception("Failed to save recipe: $e");
    }
  }

  // Fetch the shopping list after user login
  Future<List<String>> getShoppingList() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      final shoppingListSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .get();

      final shoppingList = shoppingListSnapshot.docs
          .map((doc) => List<String>.from(doc['ingredients']))
          .expand((i) => i)
          .toList();

      if (kDebugMode) {
        print("Fetched shopping list: $shoppingList");
      }

      return shoppingList;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching shopping list: $e");
      }
      throw Exception("Failed to fetch shopping list: $e");
    }
  }

  // Update display name in Firebase Authentication and Firestore
  Future<void> updateDisplayName(String name) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      await user.updateDisplayName(name);
      await user.reload();
      await _updateUserDataInFirestore(user, name);

      if (kDebugMode) {
        print("Display name updated successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating display name: $e");
      }
      throw Exception("Failed to update display name: $e");
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserDataInFirestore(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
      });

      if (kDebugMode) {
        print("User data updated in Firestore.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data in Firestore: $e");
      }
      throw Exception("Failed to update Firestore user data: $e");
    }
  }

  // Update password in Firebase Authentication
  Future<void> updatePassword(String newPassword) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      await user.updatePassword(newPassword);
      await user.reload();
      if (kDebugMode) {
        print("Password updated successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating password: $e");
      }
      throw Exception("Failed to update password: $e");
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (kDebugMode) {
        print("User signed out successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
      throw Exception("Failed to sign out: $e");
    }
  }
}
