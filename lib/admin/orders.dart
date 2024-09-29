import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateOrderStatusPage extends StatefulWidget {
  @override
  _UpdateOrderStatusPageState createState() => _UpdateOrderStatusPageState();
}

class _UpdateOrderStatusPageState extends State<UpdateOrderStatusPage> {
  String _orderId = '';
  String _status = 'Processing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Order Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Order ID'),
              onChanged: (value) {
                _orderId = value;
              },
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _status,
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              items: <String>['Processing', 'Shipped', 'Delivered']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateOrderStatus,
              child: Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus() async {
    if (_orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an Order ID')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').doc(_orderId).update({
        'status': _status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $_status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status. Please try again.')),
      );
    }
  }
}
