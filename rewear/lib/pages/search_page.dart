import 'package:flutter/material.dart';
import 'product_data.dart';
import 'product_card.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _results = List.from(kProducts);

  void _search(String query) {
    setState(() {
      _results = query.isEmpty
          ? List.from(kProducts)
          : kProducts
              .where((p) => p['name'].toString().toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          autofocus: true,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          ),
        ),
      ),
      body: _results.isEmpty
          ? const Center(child: Text('No items found', style: TextStyle(color: Colors.grey)))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final p = _results[index];
                return ProductCard(
                  product: p,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
                  ),
                );
              },
            ),
    );
  }
}
