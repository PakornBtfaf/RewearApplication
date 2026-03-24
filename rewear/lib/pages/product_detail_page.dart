import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'checkout_page.dart';
import 'login_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  String _catLabel(String? cat) => const {
        'shirt': 'Shirt', 'pants': 'Pants', 'hat': 'Hat',
        'shoes': 'Shoes', 'accessory': 'Accessory',
      }[cat] ?? cat ?? '';

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['image_url'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Image ────────────────────────────────────
          Stack(
            children: [
              SizedBox(
                height: 360,
                width: double.infinity,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPh(),
                      )
                    : _imgPh(),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_rounded, size: 17),
                        ),
                      ),
                      if (product['category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Text(
                            _catLabel(product['category']),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Details ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${product['price']} ฿',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _tag(product['size'] ?? '-'),
                      const SizedBox(width: 6),
                      if ((product['condition'] ?? '').isNotEmpty)
                        _tag(product['condition']),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Seller
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 13, color: Color(0xFF9A9A9A)),
                      const SizedBox(width: 6),
                      Text(
                        product['seller_name'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9A9A9A)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 16),

                  const Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: -0.1)),
                  const SizedBox(height: 8),
                  Text(
                    (product['description'] as String?)?.isNotEmpty == true
                        ? product['description']
                        : 'No description provided.',
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.7,
                        color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Buy button ─────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (!SupabaseService.isLoggedIn) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginPage()));
                  return;
                }
                if (product['seller_id'] == SupabaseService.currentUserId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You cannot buy your own product'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CheckoutPage(product: product)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Buy Now',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imgPh() => Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(Icons.checkroom_outlined, size: 80, color: Color(0xFFCCCCCC)),
        ),
      );

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600)),
      );
}