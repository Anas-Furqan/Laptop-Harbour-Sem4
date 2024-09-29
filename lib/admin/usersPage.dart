import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
              );
            },
          );
        },
      ),
    );
  }
}
