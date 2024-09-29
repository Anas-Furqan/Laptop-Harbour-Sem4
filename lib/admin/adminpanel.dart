import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'productsPage.dart';
import 'contactPage.dart';
import 'usersPage.dart';
import 'feedbackPage.dart';
import 'ordersPage.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: Future.wait([
            FirebaseFirestore.instance.collection('orders').get(),
            FirebaseFirestore.instance.collection('users').get(),
          ]),
          builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var ordersCount = snapshot.data![0].docs.length;
            var usersCount = snapshot.data![1].docs.length;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCountCard('Total Orders', ordersCount.toString()),
                    _buildCountCard('Total Users', usersCount.toString()),
                  ],
                ),
                SizedBox(height: 20),
                Text('Featured Laptops', style: TextStyle(fontSize: 24)),
                Image.network('https://via.placeholder.com/150', height: 200),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, String count) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        width: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(child: Text('Admin Panel')),
          ListTile(
            title: Text('Products'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsPage()));
            },
          ),
          ListTile(
            title: Text('Orders'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
            },
          ),
          ListTile(
            title: Text('Users'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage()));
            },
          ),
          ListTile(
            title: Text('Feedback'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
            },
          ),
          ListTile(
            title: Text('Contact'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage()));
            },
          ),
        ],
      ),
    );
  }
}
