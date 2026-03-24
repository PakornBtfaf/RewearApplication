import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class MyPurchasesPage extends StatefulWidget {
  const MyPurchasesPage({super.key});
  @override
  State<MyPurchasesPage> createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.getMyPurchases();
      if (mounted) setState(() => _orders = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'On Delivery': return const Color(0xFF2563EB);
      case 'Cancelled':   return const Color(0xFFDC2626);
      default:            return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Purchases',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.4)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined,
                            size: 28, color: Color(0xFFBBBBBB)),
                      ),
                      const SizedBox(height: 14),
                      const Text('No purchases yet',
                          style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final o = _orders[index];
                    final status = o['status'] ?? 'On Delivery';
                    final statusColor = _statusColor(status);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(o['seller_name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9A9A9A),
                                      fontWeight: FontWeight.w500)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(status,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 64, height: 64,
                                  color: const Color(0xFFF5F5F5),
                                  child: const Center(
                                    child: Icon(Icons.checkroom_outlined,
                                        size: 28, color: Color(0xFFCCCCCC)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(o['product_name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            letterSpacing: -0.2)),
                                    const SizedBox(height: 3),
                                    Text('Size: ${o['size'] ?? '-'}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Color(0xFF9A9A9A))),
                                    Text('${o['price']} THB',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            letterSpacing: -0.3)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (o['buyer_address'] != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: Color(0xFFAAAAAA)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(o['buyer_address'],
                                        style: const TextStyle(
                                            fontSize: 11, color: Color(0xFF888888))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}