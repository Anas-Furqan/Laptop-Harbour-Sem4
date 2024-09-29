import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submitContactMessage() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please log in to contact support.')));
      return;
    }

    String messageText = _messageController.text.trim();
    String subjectText = _subjectController.text.trim();

    if (messageText.isEmpty || subjectText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Subject and message cannot be empty.')));
      return;
    }

    // Add contact message to Firestore
    await FirebaseFirestore.instance.collection('contact').add({
      'userId': currentUser.uid,
      'subject': subjectText,
      'message': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Message sent to support!')));
    _messageController.clear();
    _subjectController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Support', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Your Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitContactMessage,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
