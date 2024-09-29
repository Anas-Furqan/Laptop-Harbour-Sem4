import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;

  CheckoutPage({required this.totalAmount});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  var uuid = Uuid();
  late String orderId = uuid.v4(); 
  String _name = '';
  String _email = '';
  String _address = '';
  String _city = '';
  String _state = '';
  String _zip = '';

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                onChanged: (value) => _name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
                onChanged: (value) => _address = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Please enter your city' : null,
                onChanged: (value) => _city = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) => value!.isEmpty ? 'Please enter your state' : null,
                onChanged: (value) => _state = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'ZIP Code'),
                validator: (value) => value!.isEmpty ? 'Please enter your ZIP code' : null,
                onChanged: (value) => _zip = value,
              ),
              SizedBox(height: 20),
              Text('Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _placeOrder();
                  }
                },
                child: Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    User? user = FirebaseAuth.instance.currentUser;


    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'orderId': orderId,
      'userId': user?.uid,
      'name': _name,
      'email': _email,
      'address': _address,
      'city': _city,
      'state': _state,
      'zip': _zip,
      'totalAmount': widget.totalAmount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully!')));
    
    Navigator.pop(context);
  }
}
