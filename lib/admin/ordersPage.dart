import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('orders').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return ListTile(
                title: Text('Order ID: ${order['orderId']}'),
                subtitle: Text('Total: \$${order['totalAmount']}'),
              );
            },
          );
        },
      ),
    );
  }
}
