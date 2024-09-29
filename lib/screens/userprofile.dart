import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _nameController.text = currentUser?.displayName ?? '';
    _emailController.text = currentUser?.email ?? '';
  }

  Future<void> _updateProfile() async {
    try {
      await currentUser?.updateDisplayName(_nameController.text);
      await currentUser?.updateEmail(_emailController.text);
      await currentUser?.reload();
      setState(() {
        currentUser = _auth.currentUser;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _changePassword() async {
    try {
      await currentUser?.updatePassword(_passwordController.text);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password changed successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Fetch wishlist items from Firestore
  Stream<QuerySnapshot> _fetchWishlistItems() {
    return FirebaseFirestore.instance
        .collection('wishlists')
        .doc(currentUser?.uid)
        .collection('userWishlist')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  currentUser?.photoURL ?? 'https://via.placeholder.com/150',
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
            Divider(),
            Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
            Divider(),
            SizedBox(height: 16),

            // Wishlist Section
            Text(
              'My Wishlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Display wishlist items
            Expanded(
              child: StreamBuilder(
                stream: _fetchWishlistItems(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var wishlistItems = snapshot.data!.docs;

                  if (wishlistItems.isEmpty) {
                    return Center(child: Text('Your wishlist is empty.'));
                  }

                  return ListView.builder(
                    itemCount: wishlistItems.length,
                    itemBuilder: (context, index) {
                      var item = wishlistItems[index];
                      return ListTile(
                        leading: Image.network(
                          item['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item['name']),
                        subtitle: Text('\$${item['price']}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
