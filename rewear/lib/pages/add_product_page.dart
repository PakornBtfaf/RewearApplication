import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});
  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();

  String? _selectedSize;
  String? _selectedCategory;
  bool _loading = false;
  File? _pickedImage;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'];
  final List<Map<String, dynamic>> _categories = [
    {'key': 'shirt',     'label': 'Shirt',     'icon': Icons.checkroom_outlined},
    {'key': 'pants',     'label': 'Pants',     'icon': Icons.accessibility_new_outlined},
    {'key': 'hat',       'label': 'Hat',       'icon': Icons.face_outlined},
    {'key': 'shoes',     'label': 'Shoes',     'icon': Icons.directions_walk_outlined},
    {'key': 'accessory', 'label': 'Accessory', 'icon': Icons.watch_outlined},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.black),
                ),
                title: const Text('Camera',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_outlined, size: 18, color: Colors.black),
                ),
                title: const Text('Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final xfile = await picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null) return;
    setState(() => _pickedImage = File(xfile.path));
  }

  Future<String?> _uploadImage(File file) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;
    final fileName = 'products/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabase.storage
        .from('images')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('images').getPublicUrl(fileName);
  }

  Future<void> _publish() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showErr('Please enter a product name'); return;
    }
    if (_selectedCategory == null) {
      _showErr('Please select a category'); return;
    }
    if (_selectedSize == null) {
      _showErr('Please select a size'); return;
    }
    if (_priceCtrl.text.trim().isEmpty || int.tryParse(_priceCtrl.text.trim()) == null) {
      _showErr('Please enter a valid price'); return;
    }

    setState(() => _loading = true);
    try {
      String? imageUrl;
      if (_pickedImage != null) imageUrl = await _uploadImage(_pickedImage!);
      await SupabaseService.addProduct({
        'name':        _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price':       int.parse(_priceCtrl.text.trim()),
        'size':        _selectedSize,
        'category':    _selectedCategory,
        'condition':   '90% New',
        'status':      'Active',
        if (imageUrl != null) 'image_url': imageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listed successfully'), backgroundColor: Colors.black),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showErr('Failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF8A8A8A), fontSize: 13, fontWeight: FontWeight.w400),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 1.2),
        ),
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
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Listing',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _loading ? null : _publish,
              child: _loading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text('Publish',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo picker ──────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: _pickedImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_pickedImage!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text('Change',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_photo_alternate_outlined,
                                size: 24, color: Color(0xFF888888)),
                          ),
                          const SizedBox(height: 12),
                          const Text('Add product photo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              )),
                          const SizedBox(height: 4),
                          const Text('Tap to upload',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFAAAAAA),
                              )),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Category ─────────────────────────────
            _sectionLabel('Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['key'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['key']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData,
                            size: 14,
                            color: isSelected ? Colors.white : const Color(0xFF666666)),
                        const SizedBox(width: 6),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF444444),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Product Name ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel('Product Name'),
                Text('${_nameCtrl.text.length}/120',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              maxLength: 120,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: _dec('Product Name', 'e.g. Navy Blue Polo Shirt'),
            ),

            const SizedBox(height: 20),

            // ── Description ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel('Description'),
                Text('${_descCtrl.text.length}/400',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLength: 400,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: _dec('Description', 'Condition, brand, how often worn...'),
            ),

            const SizedBox(height: 20),

            // ── Size ─────────────────────────────────
            _sectionLabel('Size'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _sizes.map((s) {
                final isSelected = _selectedSize == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 64,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF555555),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Price ─────────────────────────────────
            _sectionLabel('Price (THB)'),
            const SizedBox(height: 8),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: _dec('Price', 'e.g. 299'),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: -0.1,
          color: Colors.black,
        ),
      );
}