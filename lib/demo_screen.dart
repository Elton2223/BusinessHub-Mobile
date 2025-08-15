import 'package:flutter/material.dart';
import 'cards/cardWidget.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BusinessHub Demo'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to BusinessHub',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore our components and features',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      Card2Widget(
                        text: 'Analytics',
                        text2: 'Revenue',
                        text3: '+15%',
                        color: Colors.blue,
                        icon: const Icon(Icons.trending_up, color: Colors.white),
                        icon2: const Icon(Icons.analytics, color: Colors.white),
                        color01: Colors.blue,
                        action: () async {
                          // Analytics action
                        },
                      ),
                      Card2Widget(
                        text: 'Customers',
                        text2: 'Total',
                        text3: '1.2K',
                        color: Colors.green,
                        icon: const Icon(Icons.people, color: Colors.white),
                        icon2: const Icon(Icons.person_add, color: Colors.white),
                        color01: Colors.green,
                        action: () async {
                          // Customers action
                        },
                      ),
                      Card2Widget(
                        text: 'Orders',
                        text2: 'Pending',
                        text3: '24',
                        color: Colors.orange,
                        icon: const Icon(Icons.shopping_cart, color: Colors.white),
                        icon2: const Icon(Icons.receipt, color: Colors.white),
                        color01: Colors.orange,
                        action: () async {
                          // Orders action
                        },
                      ),
                      Card2Widget(
                        text: 'Products',
                        text2: 'Active',
                        text3: '156',
                        color: Colors.purple,
                        icon: const Icon(Icons.inventory, color: Colors.white),
                        icon2: const Icon(Icons.category, color: Colors.white),
                        color01: Colors.purple,
                        action: () async {
                          // Products action
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
