import 'package:flutter/material.dart';

class MyPurchasesPage extends StatelessWidget {
  final Map<String, dynamic>? newProduct;
  const MyPurchasesPage({super.key, this.newProduct});

  @override
  Widget build(BuildContext context) {
    final orders = [
      // สินค้าที่เพิ่งซื้อ (ถ้ามี)
      if (newProduct != null)
        {
          'name': newProduct!['name'],
          'shop': newProduct!['shop'],
          'size': newProduct!['size'],
          'qty': 1,
          'price': newProduct!['price'],
          'status': 'On Delivery',
        },
      // ออเดอร์ตัวอย่าง
      {'name': "Product's Name", 'shop': "Shop's Name", 'size': 'M', 'qty': 1, 'price': 599, 'status': 'On Delivery'},
      {'name': "Product's Name", 'shop': "Shop's Name", 'size': 'M', 'qty': 1, 'price': 599, 'status': 'Cancelled'},
      {'name': "Product's Name", 'shop': "Shop's Name", 'size': 'M', 'qty': 1, 'price': 599, 'status': 'Completed'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Purchases', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final o = orders[index];
          final Color statusColor;
          switch (o['status']) {
            case 'On Delivery':
              statusColor = Colors.green;
              break;
            case 'Cancelled':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.orange;
          }

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o['shop'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text(o['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.checkroom, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Size: ${o['size']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('x${o['qty']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('\$${o['price']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
