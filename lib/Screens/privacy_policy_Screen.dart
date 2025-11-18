import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color customPurple = const Color.fromARGB(255, 96, 26, 182);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark; 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        backgroundColor: customPurple, // Material Design Purple
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: 'Introduction',
                    content:
                        'Welcome to Cookify, your go-to app for discovering and sharing recipes. We value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use the Cookify app.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Data Collection',
                    content:
                        'Cookify collects the following types of information to enhance your experience:\n\n'
                        '- Personal Information: When you create a profile, we collect personal details such as your name, email address, and preferences.\n'
                        '- Usage Data: We collect information about your app usage, including search queries, recipes viewed, and interaction with features.\n'
                        '- Device Information: We collect data about the device you use, such as its model, operating system, and unique device identifiers.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Use of Data',
                    content: 'We use your data for the following purposes:\n\n'
                        '- Personalizing Your Experience: We use the data to recommend recipes based on your preferences and past activity.\n'
                        '- Improving the App: Your data helps us improve app functionality, fix bugs, and add new features.\n'
                        '- Notifications: We send push notifications to inform you about new recipes, app updates, and promotions.\n'
                        '- Communication: To send you information related to your account, such as password recovery and customer support.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Data Sharing',
                    content:
                        'We implement reasonable security measures to protect your data. However, no system is 100% secure, and we cannot guarantee the absolute security of your information.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Data Security',
                    content:
                        'We do not share your personal data with third parties except in the following cases:\n\n'
                        '- Service Providers: We may share your information with third-party vendors who help us operate the app, such as analytics services or cloud storage providers.\n'
                        '- Legal Obligations: We may disclose your data if required by law or to protect our rights, such as in cases of legal disputes or fraud prevention.\n'
                        '- Business Transfers: If Cookify is acquired or merged with another company, your information may be transferred to the new owners.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'User Rights',
                    content: 'You have the right to:\n'
                        '- Access: Request a copy of the data we hold about you.\n'
                        '- Rectify: Update or correct inaccurate information.\n'
                        '- Delete: Request the deletion of your data from our systems.\n'
                        '- Withdraw Consent: If you have consented to data collection, you can withdraw it at any time.\n'
                        'To exercise these rights, you can contact us through the app or at ',
                        emailLink: 'cookifyrecipes1234@gmail.com',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Third-Party Services',
                    content:
                        'Cookify may use third-party services for analytics, advertisements, and payment processing. These services have their own privacy policies, and we encourage you to review them. We are not responsible for their practices.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Data Retention',
                    content:
                        'We retain your data for as long as necessary to provide our services and comply with legal obligations.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Changes to the Privacy Policy',
                    content:
                        'We will notify you of any changes to this policy through app notifications or email. The changes will be effective from the date mentioned.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'Contact Information',
                    content:
                        'For privacy-related concerns, contact us at ',
                        emailLink: 'cookifyrecipes1234@gmail.com',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'International Data Transfers',
                    content:
                        'We may transfer your data across borders with appropriate safeguards in place.',
                        isDarkMode: isDarkMode,
                  ),
                  _SectionCard(
                    title: 'User Consent',
                    content:
                        'By using our app, you consent to this Privacy Policy. You can withdraw consent at any time through account settings.',
                        isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isDarkMode;
  final String? emailLink;

  const _SectionCard({
    required this.title,
    required this.content,
    required this.isDarkMode,
    this.emailLink,
  });

  @override
  Widget build(BuildContext context) {
    Color customPurple = const Color.fromARGB(255, 96, 26, 182);

    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: customPurple,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: customPurple,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: const Color.fromARGB(221, 0, 0, 0),
                fontWeight: isDarkMode ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (emailLink != null)
              GestureDetector(
                onTap: () => _launchEmail(emailLink!),
                child: Text(
                  emailLink!,
                  style: TextStyle(
                    color: customPurple, // Color of the clickable email
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Launch the email client
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch email client';
    }
  }
}
