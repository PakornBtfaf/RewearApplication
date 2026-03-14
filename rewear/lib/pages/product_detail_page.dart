import 'package:flutter/material.dart';
import 'my_purchases_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Image + Back button
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.checkroom, size: 120, color: Colors.grey),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.arrow_back_ios, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product['name'],
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '\$${product['price']}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D7A4F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Size: ${product['size']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    Text("Shop: ${product['shop']}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const Divider(height: 24),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${product['condition']} condition. Reused ${product['reused']} item. Great quality secondhand clothing.',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const Spacer(),
                    // Buy Button → ไป MyPurchasesPage
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MyPurchasesPage(newProduct: product)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Buy', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
