import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final String userId; // Add userId to fetch user-specific notifications

  const NotificationScreen({super.key, required this.userId});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // Fetch notifications from Firestore
  void _fetchNotifications() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      notifications = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'message': doc['message'],
                'unread': doc['unread'],
              })
          .toList();
    });

    // Mark all as read
    _markNotificationsAsRead();
  }

  void _markNotificationsAsRead() {
    for (var notification in notifications) {
      _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('notifications')
          .doc(notification['id'])
          .update({'unread': false});
    }
  }

  void _deleteNotification(int index) async {
    String docId = notifications[index]['id'];

    await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('notifications')
        .doc(docId)
        .delete();

    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 96, 26, 182),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notifications.isEmpty
          ? Center( // Show this when there are no notifications
              child: Text(
                'No notifications available!',
                
              ),
            )
            :ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: notifications[index]['unread'] ? Colors.red : Colors.grey,
                ),
                title: Text(notifications[index]['message']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Notification'),
                        content: const Text('Are you sure you want to delete this notification?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _deleteNotification(index);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
