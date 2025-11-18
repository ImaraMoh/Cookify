import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  final String otp;
  final String userId;

  const OTPVerificationPage({
    super.key,
    required this.email,
    required this.otp,
    required this.userId,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  bool isSubmitting = false;
  int resendTimer = 30; // Countdown timer in seconds
  late Timer _timer;
  bool canResendOTP = false;

  @override
  void initState() {
    super.initState();
    startResendOTPTimer();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  // Start countdown timer for resending OTP
  void startResendOTPTimer() {
    setState(() {
      canResendOTP = false;
      resendTimer = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
      } else {
        setState(() {
          canResendOTP = true;
        });
        timer.cancel();
      }
    });
  }

  // Verify OTP entered by the user
  Future<void> verifyOTP() async {
    String enteredOTP =
        otpControllers.map((controller) => controller.text).join();

    if (enteredOTP.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // Check if the entered OTP matches the one sent to the user
    try {
      if (enteredOTP == widget.otp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verified Successfully')),
        );
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to home screen
      } else {
        clearOTPFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP, please try again')),
        );
      }
    } catch (e) {
      clearOTPFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // Clear OTP fields on invalid attempts
  void clearOTPFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }

  // Resend OTP logic (placeholder for actual implementation)
  Future<void> resendOTP() async {
    setState(() {
      canResendOTP = false;
    });

    // Call your resend OTP API here
    try {
      // Simulate a network delay
      await Future.delayed(const Duration(seconds: 2));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Resent Successfully')),
      );

      // Restart the resend timer
      startResendOTPTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Handle field focus
  void _onFieldChanged(String value, int index) {
    if (value.length == 1 && index < otpControllers.length - 1) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter OTP sent to ${widget.email}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return OTPTextField(
                    controller: otpControllers[index],
                    onChanged: (value) => _onFieldChanged(value, index),
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : verifyOTP,
                child: isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Verify OTP'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: canResendOTP
                    ? () async {
                        await resendOTP();
                      }
                    : null,
                child: Text(
                  canResendOTP
                      ? 'Resend OTP'
                      : 'Resend OTP in $resendTimer seconds',
                  style: TextStyle(
                    color: canResendOTP ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OTPTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const OTPTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: OutlineInputBorder(),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
      ),
    );
  }
}
