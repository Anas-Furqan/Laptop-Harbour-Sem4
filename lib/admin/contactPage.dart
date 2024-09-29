import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Messages')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('contact').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return ListTile(
                title: Text(message['subject']),
                subtitle: Text(message['message']),
              );
            },
          );
        },
      ),
    );
  }
}
