import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/Screens/login_page.dart';


class StartedScreen extends StatefulWidget {
  @override
  _StartedScreenState createState() => _StartedScreenState();
}

class _StartedScreenState extends State<StartedScreen> {
  int _currentIndex = 0;
 Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  final List<Map<String, String>> features = [
    {
      'title': 'Search Recipes',
      'description': 'Find recipes by name or ingredients with smart suggestions.',
      'image': 'images/burger.png',
    },
    {
      'title': 'Plan Your Meals',
      'description': 'Organize your week with a simple and efficient meal planner.',
      'image': 'images/start2.png',
    },
    {
      'title': 'Shopping List',
      'description': 'Add ingredients to your shopping list and never forget anything.',
      'image': 'images/start3.png',
    },
    {
      'title': 'Community Chat',
      'description': 'Chat with other food lovers and share your favorite recipes.',
      'image': 'images/start4.png',
    },
  ];

void _navigateBasedOnAuthStatus(BuildContext context) async {
    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userData: {'uid': user.uid})),
      );
    } else {
      // User is not logged in, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider(
            items: features.map((feature) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(feature['image']!, height: 200),
                  SizedBox(height: 20),
                  Text(
                    feature['title']!,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Text(
                      feature['description']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                ],
              );
            }).toList(),
            options: CarouselOptions(
              height: 450,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: Duration(seconds: 2),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: features.map((feature) {
              int index = features.indexOf(feature);
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? customPurple : Colors.grey,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
             _navigateBasedOnAuthStatus(context);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: customPurple,
            ),
            child: Text(
              'Get Started',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
