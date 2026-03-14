import 'package:flutter/material.dart';
import 'add_product_page.dart';

class MyShopPage extends StatefulWidget {
  const MyShopPage({super.key});

  @override
  State<MyShopPage> createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  final List<Map<String, dynamic>> _shopProducts = [
    {'name': 'Vest Jacket', 'price': 899, 'status': 'Active'},
    {'name': 'Vest Jacket', 'price': 899, 'status': 'Sold'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Shop', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _shopProducts.isEmpty
                ? const Center(child: Text('No products yet', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _shopProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = _shopProducts[index];
                      return Column(
                        children: [
                          // Product row
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.checkroom, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('Price: \$${p['price']}'),
                                    Text(
                                      p['status'],
                                      style: TextStyle(
                                        color: p['status'] == 'Active' ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          GestureDetector(
                            onTap: () => setState(() => _shopProducts.removeAt(index)),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              ),
                              child: const Center(
                                child: Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          // Add new Product button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newProduct = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(builder: (_) => const AddProductPage()),
                  );
                  if (newProduct != null) {
                    setState(() => _shopProducts.insert(0, newProduct));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Add new Product', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
