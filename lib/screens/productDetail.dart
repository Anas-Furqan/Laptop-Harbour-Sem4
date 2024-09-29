import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  ProductDetailPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var product = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(product['image'], height: 200, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('\$${product['price']}', style: TextStyle(fontSize: 20, color: Colors.green)),
                      SizedBox(height: 10),
                      Text('Brand: ${product['brand']}'),
                      Text('Category: ${product['category']}'),
                      SizedBox(height: 20),
                      
                      // Add to Cart Button
                      ElevatedButton(
                        onPressed: () async {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please log in to add items to your cart.')));
                          } else {
                            await _addToCart(user.uid, product);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added to cart!')));
                          }
                        },
                        child: Text('Add to Cart'),
                      ),
                      SizedBox(height: 10),
                      
                      // Add to Wishlist Button
                      ElevatedButton(
                        onPressed: () async {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please log in to add items to your wishlist.')));
                          } else {
                            await _addToWishlist(user.uid, product);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added to wishlist!')));
                          }
                        },
                        child: Text('Add to Wishlist'),
                      ),
                      
                      SizedBox(height: 20),
                      _buildReviewsSection(),
                      _buildAddReviewSection(productId),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Add to Cart Functionality
  Future<void> _addToCart(String userId, DocumentSnapshot product) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').add({
      'productId': productId,
      'name': product['name'],
      'price': product['price'],
      'image': product['image'],
      'quantity': 1, 
    });
  }

  // Add to Wishlist Functionality
  Future<void> _addToWishlist(String userId, DocumentSnapshot product) async {
    await FirebaseFirestore.instance.collection('wishlists').doc(userId).collection('userWishlist').doc(productId).set({
      'productId': productId,
      'name': product['name'],
      'price': product['price'],
      'image': product['image'],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Display Reviews Section
  Widget _buildReviewsSection() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var reviews = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reviews:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...reviews.map((review) {
              return ListTile(
                title: Text(review['user']),
                subtitle: Text(review['comment']),
                trailing: Text('${review['rating']}/5'),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // Add Review Section
  Widget _buildAddReviewSection(String productId) {
    final _reviewController = TextEditingController();
    final _ratingController = TextEditingController();

    Future<void> _submitReview() async {
      if (_reviewController.text.isEmpty || _ratingController.text.isEmpty) {
        return;
      }

      await FirebaseFirestore.instance.collection('products').doc(productId).collection('reviews').add({
        'user': 'Anonymous',
        'comment': _reviewController.text,
        'rating': int.parse(_ratingController.text),
      });

      _reviewController.clear();
      _ratingController.clear();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leave a Review:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: _reviewController,
          decoration: InputDecoration(labelText: 'Your Review'),
        ),
        TextField(
          controller: _ratingController,
          decoration: InputDecoration(labelText: 'Rating (1-5)'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submitReview,
          child: Text('Submit Review'),
        ),
      ],
    );
  }
}
