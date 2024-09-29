import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackForm extends StatefulWidget {
  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _feedbackController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submitFeedback() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please log in to submit feedback.')));
      return;
    }

    String feedbackText = _feedbackController.text.trim();

    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Feedback cannot be empty.')));
      return;
    }

    // Add feedback to Firestore
    await FirebaseFirestore.instance.collection('feedback').add({
      'userId': currentUser.uid,
      'feedback': feedbackText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Feedback submitted successfully!')));
    _feedbackController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit your Feedback', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
