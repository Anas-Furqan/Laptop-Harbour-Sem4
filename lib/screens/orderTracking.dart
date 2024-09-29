import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackingPage extends StatefulWidget {
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final _formKey = GlobalKey<FormState>();
  String _orderId = '';
  Map<String, dynamic>? _orderDetails;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Your Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Enter Order ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your Order ID' : null,
                    onChanged: (value) {
                      _orderId = value;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _trackOrder,
                    child: Text('Track Order'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : _orderDetails != null
                    ? _buildOrderDetails()
                    : Text('Enter your order ID to track your order.'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: $_orderId', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${_orderDetails!['status']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Shipping Address: ${_orderDetails!['address']}'),
            SizedBox(height: 10),
            Text('Total Amount: \$${_orderDetails!['totalAmount']}'),
          ],
        ),
      ),
    );
  }

  Future<void> _trackOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(_orderId)
          .get();

      if (orderSnapshot.exists) {
        setState(() {
          _orderDetails = orderSnapshot.data() as Map<String, dynamic>?;
          _loading = false;
        });
      } else {
        setState(() {
          _orderDetails = null;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order not found. Please check your Order ID.')),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error tracking order. Please try again.')),
      );
    }
  }
}
