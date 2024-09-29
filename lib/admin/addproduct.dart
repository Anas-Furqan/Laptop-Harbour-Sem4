import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddProductPage extends StatefulWidget {
  @override
  _AdminAddProductPageState createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  Future<void> _addProduct() async {
    try {
      // Generate a unique product ID
      DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc();

      // Save product details in Firebase
      await productRef.set({
        'id': productRef.id, // Auto-generated ID
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'brand': _brandController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image': _imageUrlController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully!')));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding product.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _brandController,
              decoration: InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
