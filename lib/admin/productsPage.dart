import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('products').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('\$${product['price']}'),
                leading: Image.network(product['image'], width: 50, height: 50),
              );
            },
          );
        },
      ),
    );
  }
}
