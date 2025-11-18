import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/login_page.dart';
import 'package:mobile_app/Screens/privacy_policy_Screen.dart';

class SignUpReminderPage extends StatelessWidget {
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.cancel, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        backgroundColor: Colors.white12, // No background color for the app bar
        elevation: 0, // Remove the elevation (shadow)
      ),
      body: SingleChildScrollView( // Wrap the entire body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Image at the top
              Image.asset('images/signup1.webp', height: 250), // Add your image asset here
              const SizedBox(height: 5),

              // Text explaining why the user should sign up
              const Text(
                'Sign up to unlock exclusive features like meal planning, saved recipes, and much more!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Google, Facebook, and Email options
              Column(
                children: [
                  _buildSocialButton(
                    context,
                    label: 'Sign Up with Google',
                    imagePath: 'images/google.png',
                    onPressed: () {
                      // Implement Google sign-up logic here
                    },
                  ),
                  _buildSocialButton(
                    context,
                    label: 'Sign Up with Facebook',
                    imagePath: 'images/fb.png',
                    onPressed: () {
                      // Implement Facebook sign-up logic here
                    },
                  ),
                  _buildSocialButton(
                    context,
                    label: 'Sign Up with Email',
                    imagePath: 'images/email.png',
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(),)
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // Privacy Policy Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'By signing up, I accept the ',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen(),)
                      );
                    },
                    child:  Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        color: customPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Already have an account? Login here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 14, color: Colors.black87 ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(),)
                      );
                    },
                    child:  Text(
                      'Log in ',
                      style: TextStyle(
                        fontSize: 16,
                        color: customPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create social sign-up buttons
  Widget _buildSocialButton(BuildContext context, {required String label, required String imagePath, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          imagePath,
          width: 24,  // Set the width of the image
          height: 24, // Set the height of the image
        ),
        label: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          side: BorderSide(color: Colors.black, width: 1.5), // Border color and thickness
        ),
      ),
    );
  }
}
