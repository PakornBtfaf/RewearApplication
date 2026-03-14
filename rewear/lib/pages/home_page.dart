import 'package:flutter/material.dart';
import 'product_data.dart';
import 'product_card.dart';
import 'search_page.dart';
import 'product_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  //กดแล้วไป SearchPage
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                          const SizedBox(width: 8),
                          Text('Search', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Welcome banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Hi, Username\nYou saved 3 items 🌿',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D7A4F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: kProducts.length,
                itemBuilder: (context, index) {
                  final p = kProducts[index];
                  return ProductCard(
                    product: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
