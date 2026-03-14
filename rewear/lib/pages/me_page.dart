import 'package:flutter/material.dart';
import 'my_purchases_page.dart';
import 'my_shop_page.dart';
import 'eco_page.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Profile header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 36, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Username', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Eco Level: Beginner', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _menuItem(
              context,
              icon: Icons.shopping_bag_outlined,
              label: 'My Purchases',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPurchasesPage())),
            ),
            _menuItem(
              context,
              icon: Icons.storefront_outlined,
              label: 'My Store',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyShopPage())),
            ),
            _menuItem(
              context,
              icon: Icons.eco_outlined,
              label: 'Eco Dashboard',
              color: const Color(0xFF2D7A4F),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EcoPage())),
            ),
            _menuItem(
              context,
              icon: Icons.logout,
              label: 'logout',
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.black87),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? Colors.black87)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
