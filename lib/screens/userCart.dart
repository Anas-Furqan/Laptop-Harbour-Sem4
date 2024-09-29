import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Shopping Cart'),
        ),
        body: Center(
          child: Text('Please log in to view your cart.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('cart').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return Center(child: Text('Your cart is empty.'));
          }

          double totalAmount = 0;
          cartItems.forEach((cartItem) {
            totalAmount += cartItem['price'] * cartItem['quantity'];
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = cartItems[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(cartItem['image'], width: 50, fit: BoxFit.cover),
                        title: Text(cartItem['name']),
                        subtitle: Text('\$${cartItem['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                _updateQuantity(cartItem.id, -1);
                              },
                            ),
                            Text('${cartItem['quantity']}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _updateQuantity(cartItem.id, 1);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _removeItem(cartItem.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Total: \$${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutPage(totalAmount: totalAmount)),
                        );
                      },
                      child: Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateQuantity(String cartItemId, int change) async {
    DocumentReference cartItemRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('cart').doc(cartItemId);
    DocumentSnapshot cartItemSnapshot = await cartItemRef.get();

    if (cartItemSnapshot.exists) {
      int currentQuantity = cartItemSnapshot['quantity'];
      int newQuantity = currentQuantity + change;

      if (newQuantity > 0) {
        await cartItemRef.update({'quantity': newQuantity});
      } else {
        await _removeItem(cartItemId); 
      }
    }
  }

  Future<void> _removeItem(String cartItemId) async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('cart').doc(cartItemId).delete();
  }
}
