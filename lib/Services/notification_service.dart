import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

  NotificationService() {
    initializeNotifications();
  }
  
  Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: darwinSettings);
    await notificationsPlugin.initialize(settings);

    if (kDebugMode) {
      print("🎉 Notifications initialized successfully!");
    }
  }

  // Define notification details (with larger text for better readability)
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'meal_channel_id',
        'Meal Reminders',
        channelDescription: 'Notification channel for meal reminders',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''), // Allow big text style for longer messages
      ),
    );
  }

  // Show a simple notification
  Future<void> showNotification({
    int id = 1,
    String? category,
    String? formattedDate,
    String? mealName,
  }) async {
    String message = "You plan your $category meal: $mealName, for $formattedDate!"; // Ensure proper formatting
    return notificationsPlugin.show(
      id,
      'Meal Added for $formattedDate',
      message,
      notificationDetails(),
      payload: 'notification_payload',
    );
  }

  // Schedule a notification at a specific time
  Future<void> scheduleNotification({
    int id = 1,
    required String category,
    required String formattedDate,
    required DateTime scheduledTime,
    required String mealName,
  }) async {
    if (kDebugMode) {
      print('Scheduling notification: $category - $mealName at $scheduledTime');
    }

    showNotification(category: category, mealName: mealName, formattedDate: formattedDate);

    await notificationsPlugin.zonedSchedule(
      id = 1,
      category,
      mealName,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      print('Notification saved and scheduled for $scheduledTime');
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancelAll();
  }

  // Save notification to Firestore and schedule local notification
  Future<void> saveNotification(String userId, String category, String mealName, String Date) async {
    try {
      // Check if the meal is already scheduled
      bool isAlreadyScheduled = await checkIfMealAlreadyScheduled(userId, category, mealName);

      if (isAlreadyScheduled) {
        if (kDebugMode) {
          print("Meal '$mealName' in category '$category' is already scheduled. Skipping notification.");
        }
        return; // Skip scheduling if the meal is already scheduled
      }

      Duration notificationDuration;

      switch (category.toLowerCase()) {
        default:
          notificationDuration = Duration(seconds: 10);
          break;
      }

      DateTime mealTime = DateTime.now().add(notificationDuration);

      // Save the meal to Firestore before scheduling the notification
      await saveMealToFirestore(userId, category, mealName, Date, mealTime);

      scheduleNotification(
        category: category,
        mealName: mealName,
        scheduledTime: mealTime,
        formattedDate: Date,
      );
      if (kDebugMode) {
        print('Saved notification for $mealName at $mealTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notification: $e');
      }
    }
  }

  // Method to check if a meal with the same category and name is already scheduled
  Future<bool> checkIfMealAlreadyScheduled(String userId, String category, String mealName) async {
    try {
      // Query Firestore to check for an existing meal schedule
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealScheduled')
          .where('category', isEqualTo: category)
          .where('mealName', isEqualTo: mealName)
          .get();

      // If the snapshot contains documents, that means the meal is already scheduled
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking if meal is already scheduled: $e");
      }
      return false;
    }
  }

  // Method to save the meal to Firestore
  Future<void> saveMealToFirestore(String userId, String category, String mealName, String Date, DateTime mealTime) async {
    try {
      // Save the scheduled meal in Firestore under the user's collection
      await _firestore.collection('users').doc(userId).collection('mealScheduled').add({
        'category': category,
        'mealName': mealName,
        'Date': Date,
        'mealTime': mealTime.toIso8601String(),
      });

      if (kDebugMode) {
        print("Meal '$mealName' saved to Firestore.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving meal to Firestore: $e");
      }
    }
  }

}
