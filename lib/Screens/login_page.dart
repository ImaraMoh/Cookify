import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/Screens/otp_verification_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLogin = true;
  bool isPasswordVisible = false;
  final Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userData: {'uid': user.uid})),
        );
      }
    });
  }

  Future<void> signInWithEmailAndPassword() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showErrorSnackbar('Email and Password cannot be empty');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userData: {'uid': userCredential.user!.uid})),
        );
      } else {
        if (userCredential.user != null && userCredential.user!.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userData: {'uid': userCredential.user!.uid})),
          );
        } else {
          showErrorSnackbar('Please verify your email before logging in');
        }
      }
    } on FirebaseAuthException catch (e) {
      showErrorSnackbar(e.message ?? 'Error occurred while signing in');
    }
  }

  final Auth _auth = Auth();

  Future<UserCredential> createUserWithEmailAndPassword({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();

      await _auth._saveUserData(userCredential.user!, name);

      String otp = generateOTP(); 
      await saveOTPToFirestore(userId, otp);
      await sendEmail(email, otp); 

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(
            email: email,
            otp: otp, userId: 'userId',
          ),
        ),
      );

      return userCredential;
    } catch (e) {
      throw Exception("User creation failed: $e");
    }
  }

  Future<void> saveOTPToFirestore(String userId, String otp) async {
    final expirationTime = DateTime.now().add(const Duration(minutes: 5));

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'otp': otp,
      'otpExpiration': expirationTime,
      'otpAttempts': 0,
    });
  }

  Future<void> sendEmail(String email, String otp) async {
    final smtpServer = gmail('cookifyrecipes1234@gmail.com', 'ottk glee trub cgqv');

    final message = Message()
      ..from = Address('cookifyrecipes1234@gmail.com', 'Cookify Team')
      ..recipients.add(email)
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

  void clearTextFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.green))),
    );
  }

  Widget buildTextField({
    required String labelText,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.black), // Set text color to black
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black), // Set label text color to black
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: customPurple) : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color.fromARGB(255, 231, 207, 236), const Color.fromARGB(255, 237, 215, 195)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'images/cookifylogo.png',
                    height: 250,
                  ),
                ),
                const SizedBox(height: 0),

                // Rounded Box Container for Login/SignUp
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Toggle between Login and Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => isLogin = true),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isLogin ? customPurple : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          GestureDetector(
                            onTap: () => setState(() => isLogin = false),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isLogin ? Colors.grey : customPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Fields
                      if (!isLogin)
                        buildTextField(
                          labelText: 'Name',
                          controller: nameController,
                          prefixIcon: Icons.person, // Name icon
                        ),
                      buildTextField(
                        labelText: 'Email',
                        controller: emailController,
                        prefixIcon: Icons.email, // Email icon
                      ),
                      buildTextField(
                        labelText: 'Password',
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        prefixIcon: Icons.lock, // Password icon
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: isDarkMode ? customPurple : customPurple,
                          ),
                          onPressed: () => setState(
                              () => isPasswordVisible = !isPasswordVisible),
                        ),
                      ),
                      const SizedBox(height: 0),

                      // Forgot Password Button
                      if (isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextButton(
                              onPressed: () {
                                if (emailController.text.isNotEmpty) {
                                  sendPasswordResetEmail(emailController.text.trim());
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter your email to reset the password.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: customPurple,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      // Login/SignUp Button
                      ElevatedButton(
                        onPressed: isLogin
                            ? signInWithEmailAndPassword
                            : () => createUserWithEmailAndPassword(
                                  context: context,
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  name: nameController.text.trim(),
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Do it Later Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(
                                userData: {
                                  'name': 'Guest',
                                  'email': 'guest@example.com',
                                  'preferences': {},
                                },
                              ),
                            ),
                          );
                        },
                        child:  Text(
                          'Do it Later',
                          style: TextStyle(color: customPurple),
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String generateOTP() {
    final random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class Auth {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveUserData(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
}