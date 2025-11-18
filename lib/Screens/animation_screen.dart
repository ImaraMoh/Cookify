import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/Screens/get_started.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/Screens/start.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOutAnimation;
  bool _isUserLoggedIn = false; // Track login status

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Check if user is logged in
    checkUserLoginStatus();
  }

  Future<void> checkUserLoginStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isUserLoggedIn = user != null;
    });

    // Navigate after animation ends
    Timer(const Duration(seconds: 4), () {
      if (_isUserLoggedIn) {
        // Navigate to HomeScreen if logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userData: {'uid': user!.uid})),
        );
      } else {
        // Navigate to GetStartedScreen if not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  StartedScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Food animations and logo animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeOutAnimation.value,
                child: Stack(
                  children: [
                    _buildFoodItem(
                      screenSize,
                      'images/pizza.png',
                      const Offset(0.1, 0.7),
                      rotate: true,
                    ),
                    _buildFoodItem(
                      screenSize,
                      'images/burger.png',
                      const Offset(0.4, 0.4),
                      flowDirection: Axis.horizontal,
                    ),
                    _buildFoodItem(
                      screenSize,
                      'images/cupcake.png',
                      const Offset(0.7, 0.7),
                      rotate: true,
                      flowDirection: Axis.vertical,
                    ),
                    _buildFoodItem(
                      screenSize,
                      'images/sushi.png',
                      const Offset(0.2, 0.2),
                      scaleEffect: true,
                    ),
                    _buildFoodItem(
                      screenSize,
                      'images/fruits.png',
                      const Offset(0, 0.3),
                      flowDirection: Axis.vertical,
                      rotate: true,
                    ),
                    Center(
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 2),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: Image.asset(
                          'images/cookifylogo.png',
                          height: 200,
                          width: 200,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Helper method to create animated food items
  Widget _buildFoodItem(
    Size screenSize,
    String imagePath,
    Offset position, {
    bool rotate = false,
    Axis flowDirection = Axis.vertical,
    bool scaleEffect = false,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = child!;

        if (rotate) {
          animatedChild = Transform.rotate(
            angle: _controller.value * 2 * 3.14,
            child: animatedChild,
          );
        }

        if (scaleEffect) {
          animatedChild = Transform.scale(
            scale: 1 + 0.4 * (1 - _controller.value),
            child: animatedChild,
          );
        }

        double offsetValue = (_controller.value * 0.1) * screenSize.height;
        double newTop = position.dy * screenSize.height;
        double newLeft = position.dx * screenSize.width;

        if (flowDirection == Axis.vertical) {
          newTop += offsetValue * ((position.dy < 0.5) ? 1 : -1);
        } else if (flowDirection == Axis.horizontal) {
          newLeft += offsetValue * ((position.dx < 0.5) ? 1 : -1);
        }

        return Positioned(
          top: newTop,
          left: newLeft,
          child: animatedChild,
        );
      },
      child: Image.asset(
        imagePath,
        height: 100,
        width: 100,
      ),
    );
  }
}
