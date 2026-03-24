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

  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'shirt',
      'label': 'Shirt',
      'icon': Icons.checkroom_outlined,
      'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'],
      'sizeLabel': 'Size',
    },
    {
      'key': 'pants',
      'label': 'Pants',
      'icon': Icons.straighten_outlined,
      'sizes': ['28', '30', '32', '34', '36', '38'],
      'sizeLabel': 'Waist (inches)',
    },
    {
      'key': 'hat',
      'label': 'Hat',
      'icon': Icons.face_outlined,
      'sizes': ['Free Size', 'S/M', 'M/L'],
      'sizeLabel': 'Size',
    },
    {
      'key': 'shoes',
      'label': 'Shoes',
      'icon': Icons.hiking_outlined,
      'sizes': ['36', '37', '38', '39', '40', '41', '42', '43', '44', '45'],
      'sizeLabel': 'EU Size',
    },
    {
      'key': 'accessory',
      'label': 'Accessory',
      'icon': Icons.watch_outlined,
      'sizes': ['Free Size'],
      'sizeLabel': 'Size',
    },
  ];

  /// คืน sizes list ของ category ที่เลือก
  List<String> get _currentSizes {
    if (_selectedCategory == null) return [];
    final cat = _categories.firstWhere(
      (c) => c['key'] == _selectedCategory,
      orElse: () => _categories.first,
    );
    return List<String>.from(cat['sizes'] as List);
  }

  /// คืน label ของ size field
  String get _sizeLabelText {
    if (_selectedCategory == null) return 'Size';
    final cat = _categories.firstWhere(
      (c) => c['key'] == _selectedCategory,
      orElse: () => _categories.first,
    );
    return cat['sizeLabel'] as String;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  /// เมื่อเปลี่ยน category ให้ reset size ที่เลือก
  void _onCategoryChanged(String key) {
    setState(() {
      _selectedCategory = key;
      _selectedSize = null; // reset เสมอเมื่อ category เปลี่ยน
    });
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (source == null) return;
    final xfile = await picker.pickImage(source: source, imageQuality: 80);
    if (xfile == null) return;
    setState(() => _pickedImage = File(xfile.path));
  }

  Future<String?> _uploadImage(File file) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;
    final fileName =
        'products/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabase.storage
        .from('images')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('images').getPublicUrl(fileName);
  }

  Future<void> _publish() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter a product name');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }
    if (_selectedSize == null) {
      _showError('Please select a size');
      return;
    }
    if (_priceCtrl.text.trim().isEmpty ||
        int.tryParse(_priceCtrl.text.trim()) == null) {
      _showError('Please enter a valid price');
      return;
    }

    setState(() => _loading = true);
    try {
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
      }

      await SupabaseService.addProduct({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': int.parse(_priceCtrl.text.trim()),
        'size': _selectedSize,
        'category': _selectedCategory,
        'condition': '90% New',
        'status': 'Active',
        if (imageUrl != null) 'image_url': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product published'),
            backgroundColor: Colors.black,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showError('Failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        counterText: '',
      );

  @override
  Widget build(BuildContext context) {
    final sizes = _currentSizes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Listing',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _loading ? null : _publish,
              child: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2),
                    )
                  : const Text(
                      'Publish',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ─────────────────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                clipBehavior: Clip.hardEdge,
                child: _pickedImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_pickedImage!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Change photo',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Add photo',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to upload',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Category ───────────────────────────────────
            const Text('Category',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['key'];
                return GestureDetector(
                  onTap: () => _onCategoryChanged(cat['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Name ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Product Name',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${_nameCtrl.text.length}/120',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              maxLength: 120,
              onChanged: (_) => setState(() {}),
              decoration:
                  _dec('Product Name', 'e.g. Navy Blue Polo Shirt'),
            ),

            const SizedBox(height: 20),

            // ── Description ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Description',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${_descCtrl.text.length}/400',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLength: 400,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: _dec(
                  'Description', 'Condition, brand, how often worn...'),
            ),

            const SizedBox(height: 20),

            // ── Size ──────────────────────────────────────
            // แสดง size section เฉพาะเมื่อเลือก category แล้ว
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedCategory == null
                  // ยังไม่เลือก category
                  ? Container(
                      key: const ValueKey('no-category'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.grey.shade200,
                            style: BorderStyle.solid),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.grey.shade400),
                          const SizedBox(width: 8),
                          Text(
                            'Select a category to see size options',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    )
                  // เลือก category แล้ว → แสดง size picker
                  : Column(
                      key: ValueKey(_selectedCategory),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _sizeLabelText,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            // Badge บอกประเภทไซต์
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getCategoryLabel(_selectedCategory),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // แสดงเป็น chips แทน dropdown
                        _buildSizeChips(sizes),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // ── Price ────────────────────────────────────
            const Text('Price (THB)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: _dec('Price', 'e.g. 299'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// สร้าง size chips grid
  Widget _buildSizeChips(List<String> sizes) {
    // รองเท้ามีไซต์เยอะ → ใช้ Wrap แบบกระชับ
    // อื่น ๆ → ใช้ Row / Wrap ปกติ
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((size) {
        final isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => _selectedSize = size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: _chipWidth(sizes.length),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade200,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              size,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// คำนวณความกว้าง chip ตามจำนวนไซต์
  double _chipWidth(int count) {
    final screenWidth = MediaQuery.of(context).size.width - 40; // padding 20*2
    // รองเท้า 10 ไซต์ → 5 คอลัมน์
    if (count >= 8) return (screenWidth - 8 * 4) / 5;
    // pants 6 ไซต์ → 3 คอลัมน์
    if (count >= 5) return (screenWidth - 8 * 2) / 3;
    // hat / accessory ≤ 3 → auto
    return (screenWidth - 8 * (count - 1)) / count;
  }

  String _getCategoryLabel(String? key) {
    switch (key) {
      case 'shirt':     return 'Clothing size';
      case 'pants':     return 'Waist size';
      case 'hat':       return 'Head size';
      case 'shoes':     return 'EU shoe size';
      case 'accessory': return 'One size';
      default:          return '';
    }
  }
}