import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('feedback').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var feedbackList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              var feedback = feedbackList[index];
              return ListTile(
                title: Text(feedback['userId']),
                subtitle: Text(feedback['feedback']),
              );
            },
          );
        },
      ),
    );
  }
}
