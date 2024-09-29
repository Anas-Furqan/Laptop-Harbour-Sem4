import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
import 'screens/productDetail.dart';
import 'screens/userCart.dart';
import 'screens/userprofile.dart';
import 'screens/contact.dart';
import 'screens/feedback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaptopHarbor',
      initialRoute: '/',
    routes: {
      '/': (context) => MainPage(),
      '/profile': (context) => ProfilePage(),
      '/login': (context) => LoginScreen(),
    },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  User? currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // String _selectedBrand = 'All';
  // String _selectedCategory = 'All';
  // double _selectedPrice = 1000;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    // _checkLoggedInUser();
  }

  // void _checkLoggedInUser() {
  //   _user = FirebaseAuth.instance.currentUser;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LaptopHarbor"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.feedback),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackForm()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.contact_page),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactForm()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),
          if (currentUser != null)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          currentUser!.photoURL ??
                              'https://via.placeholder.com/150', // Default image
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(currentUser!.displayName ?? 'User'),
                    ],
                  ),
                ),
                items: <String>['Profile', 'Logout'].map((String choice) {
                  return DropdownMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == 'Profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'Logout') {
                    _auth.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'New Arrivals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSection(),
                Expanded(child: _buildProductGrid()),
              ],
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://via.placeholder.com/800x200.png?text=Big+Laptop+Sale'), // Replace with actual image
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Filter Section
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            hint: Text('Filter by Category'),
            items: ['Laptops', 'Accessories']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
          DropdownButton<String>(
            hint: Text('Sort by Price'),
            items: ['Low to High', 'High to Low']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            return Card(
              child: Column(
                children: [
                  Image.network(
                    product['image'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'], style: TextStyle(fontSize: 16)),
                        Text('\$${product['price']}',
                            style: TextStyle(color: Colors.green)),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(productId: product['id']),
                              ),
                            );
                          },
                          child: Text('View More'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Center(
        child: Text('© 2024 LaptopHarbor. All rights reserved.'),
      ),
    );
  }
}


class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No results found.'),
          );
        }

        final results = snapshot.data!.docs;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var product = results[index];

            return ListTile(
              leading: Image.network(product['image'], width: 50, fit: BoxFit.cover),
              title: Text(product['name']),
              subtitle: Text("\$${product['price']}"),
              onTap: () {
                Navigator.pushNamed(context, '/productDetails', arguments: product.id);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final suggestions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            var product = suggestions[index];
            return ListTile(
              leading: Image.network(product['image'], width: 50, fit: BoxFit.cover),
              title: Text(product['name']),
              subtitle: Text("\$${product['price']}"),
              onTap: () {
                query = product['name'];
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}