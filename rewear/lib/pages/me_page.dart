import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'my_purchases_page.dart';
import 'my_shop_page.dart';
import 'eco_page.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});
  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  Map<String, dynamic>? _profile;
  int _buyCount = 0;
  bool _loading = true;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final profile = await SupabaseService.getProfile();
      final count   = await SupabaseService.getBuyCount();
      if (mounted) setState(() { _profile = profile; _buyCount = count; });
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _ecoLevel(int count) {
    if (count >= 21) return 'Planet Saver';
    if (count >= 11) return 'Green Hero';
    if (count >= 6)  return 'Eco Lover';
    if (count >= 3)  return 'Starter';
    return 'Beginner';
  }

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                      borderRadius: BorderRadius.circular(8)),
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
                      borderRadius: BorderRadius.circular(8)),
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
    final xfile = await picker.pickImage(source: source, imageQuality: 80);
    if (xfile == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final file = File(xfile.path);
      final userId = SupabaseService.currentUserId!;
      final fileName = 'avatars/$userId.jpg';
      await supabase.storage.from('images').upload(
        fileName, file,
        fileOptions: const FileOptions(upsert: true),
      );
      final url = supabase.storage.from('images').getPublicUrl(fileName);
      final urlWithBust = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      await supabase.from('profiles').upsert({'id': userId, 'avatar_url': urlWithBust});
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sign out?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3)),
        content: const Text('You will be returned to the login screen.',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await SupabaseService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final name = _profile?['display_name'] ??
        user?.userMetadata?['full_name'] ?? 'User';
    final email = _profile?['email'] ?? user?.email ?? '';
    final avatarUrl = _profile?['avatar_url'] as String?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Profile card ──────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      child: Row(
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: _changeAvatar,
                            child: Stack(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  clipBehavior: Clip.hardEdge,
                                  child: _uploadingAvatar
                                      ? Container(
                                          color: const Color(0xFFF0F0F0),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.black, strokeWidth: 1.5)))
                                      : avatarUrl != null && avatarUrl.isNotEmpty
                                          ? Image.network(avatarUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _initialsWidget(initial))
                                          : _initialsWidget(initial),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    width: 22, height: 22,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                        color: Colors.black)),
                                const SizedBox(height: 2),
                                Text(email,
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF9A9A9A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _ecoLevel(_buyCount),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Stats row ─────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statCol('$_buyCount', 'Purchases'),
                          Container(width: 1, height: 32, color: const Color(0xFFEEEEEE)),
                          _statCol(_ecoLevel(_buyCount), 'Eco Level'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Menu ──────────────────────────────
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.shopping_bag_outlined,
                            label: 'My Purchases',
                            subtitle: '$_buyCount items',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyPurchasesPage()),
                            ).then((_) => _loadData()),
                          ),
                          _divider(),
                          _menuTile(
                            icon: Icons.storefront_outlined,
                            label: 'My Shop',
                            subtitle: 'Manage listings',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyShopPage()),
                            ),
                          ),
                          _divider(),
                          _menuTile(
                            icon: Icons.eco_outlined,
                            label: 'Eco Dashboard',
                            subtitle: 'Your impact',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EcoPage()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      color: Colors.white,
                      child: _menuTile(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        labelColor: Colors.red,
                        onTap: _logout,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _initialsWidget(String letter) => Container(
        color: const Color(0xFFF0F0F0),
        child: Center(
          child: Text(letter,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
        ),
      );

  Widget _statCol(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9A9A9A))),
        ],
      );

  Widget _menuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
    Color? labelColor,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: labelColor ?? Colors.black),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: -0.2,
                            color: labelColor ?? Colors.black)),
                    if (subtitle != null)
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFAAAAAA))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.grey.shade300),
            ],
          ),
        ),
      );

  Widget _divider() =>
      const Divider(color: Color(0xFFF5F5F5), height: 1, indent: 70);
}