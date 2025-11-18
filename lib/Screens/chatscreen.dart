import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for formatting timestamps

class CommunityChatScreen extends StatefulWidget {
  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> messages = [];
  TextEditingController _messageController = TextEditingController();
  String? _userName;
  String? _userProfilePicUrl;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);
  @override
  void initState() {
    super.initState();
    _initializeUser();
    _fetchMessages();
  }

  Future<void> _initializeUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? "User";
        _userProfilePicUrl = user.photoURL;
      });
    }
  }

  void _fetchMessages() async {
    FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messages = snapshot.docs.map((doc) {
          Timestamp timestamp = doc['timestamp'] ?? Timestamp.now();
          return {
            'message': doc['message'],
            'sender': doc['sender'],
            'timestamp': timestamp,
            'profilePic': doc['profilePic'],
          };
        }).toList();
      });
    });
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text;

      await FirebaseFirestore.instance.collection('messages').add({
        'message': message,
        'sender': _userName,
        'timestamp': FieldValue.serverTimestamp(),
        'profilePic': _userProfilePicUrl ?? "",
      });

      _messageController.clear();
    }
  }

 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;
  String? lastDate;

  return Scaffold(
    extendBodyBehindAppBar: true, // Extend body behind the AppBar
    appBar: AppBar(
      title: Text(
        "Our Community",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      ),
      backgroundColor:customPurple, // Transparent AppBar
      elevation: 0, // Remove shadow
    ),
    body: Container(
      
      child: Column(
        children: [
       Expanded(
  child: ListView.builder(
    reverse: false, // Ensures messages appear in the correct order
    itemCount: messages.length,
    itemBuilder: (context, index) {
      final messageData = messages[index];
      final String message = messageData['message']!;
      final String sender = messageData['sender']!;
      final Timestamp timestamp = messageData['timestamp'];
      final DateTime dateTime = timestamp.toDate();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      bool isCurrentUser = sender == _userName;

      // Show the date header if this is the first message of the day
      bool showDateHeader = index == 0 ||
        DateFormat('yyyy-MM-dd').format(messages[index - 1]['timestamp'].toDate()) != formattedDate;

      // Show the sender's name only if it's the first message in a sequence
      bool showSenderName = index == 0 || messages[index - 1]['sender'] != sender;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDateHeader)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              alignment: Alignment.center,
              child: Text(
                formattedDate,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode? Colors.white :Colors.black),
              ),
            ),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCurrentUser && showSenderName)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 20.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: customPurple, // Default color if no profile pic
                    child: Text(
                      sender[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                SizedBox(width: 68),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser && showSenderName)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0, left: 10.0),
                        child: Text(
                          sender,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:isDarkMode? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    
                    Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? selectedPurple
                              : const Color.fromARGB(255, 210, 196, 209),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(
                          
                          maxWidth: MediaQuery.of(context).size.width * 0.45,
                          minWidth: 100,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              softWrap: true,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                DateFormat.jm().format(dateTime),
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    },
  ),
),



          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 30),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 210, 196, 209).withOpacity(0.8),
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: customPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
