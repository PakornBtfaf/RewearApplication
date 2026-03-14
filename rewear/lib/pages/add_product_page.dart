import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String? _selectedSize;
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _publish() {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
      );
      return;
    }
    // ส่งข้อมูลกลับไปที่ MyShopPage
    Navigator.pop(context, {
      'name': _nameCtrl.text.trim(),
      'price': int.tryParse(_priceCtrl.text.trim()) ?? 0,
      'status': 'Active',
      'size': _selectedSize,
    });
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D7A4F)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        counterText: '',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Media
            const Text('Product Media *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 28),
                  Text('Add Photo', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Product Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${_nameCtrl.text.length}/120', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              maxLength: 120,
              onChanged: (_) => setState(() {}),
              decoration: _dec('Enter Product Name'),
            ),
            const SizedBox(height: 16),

            // Description
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Description *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${_descCtrl.text.length}/400', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLength: 400,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: _dec('Enter Product Description'),
            ),
            const SizedBox(height: 16),

            // Size
            const Text('Size *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedSize,
              hint: const Text('Select'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: _sizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _selectedSize = v),
            ),
            const SizedBox(height: 16),

            // Price
            const Text('Price *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: _dec('0.00'),
            ),
            const SizedBox(height: 32),

            // Publish Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Publish', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
