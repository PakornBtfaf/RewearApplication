import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase client shorthand - ใช้ได้ทุกที่
final supabase = Supabase.instance.client;

class SupabaseService {
  // ─── AUTH ───────────────────────────────────────────────
  static User? get currentUser => supabase.auth.currentUser;
  static String? get currentUserId => supabase.auth.currentUser?.id;
  static bool get isLoggedIn => supabase.auth.currentUser != null;

  // Sign out
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ─── PROFILES ───────────────────────────────────────────

  /// ดึง profile ของ user ปัจจุบัน
  static Future<Map<String, dynamic>?> getProfile() async {
    if (currentUserId == null) return null;
    final res = await supabase
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    return res;
  }

  /// สร้างหรืออัปเดต profile → เรียกอัตโนมัติหลัง sign-up / sign-in
  ///
  /// ต้องมี table `profiles` ใน Supabase:
  ///   id          uuid  (FK → auth.users.id, primary key)
  ///   display_name text
  ///   email       text
  ///   avatar_url  text (nullable)
  ///   created_at  timestamptz (default now())
  static Future<void> upsertProfile({
    required String userId,
    required String displayName,
    required String email,
    String? avatarUrl,
  }) async {
    await supabase.from('profiles').upsert(
      {
        'id': userId,
        'display_name': displayName,
        'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      onConflict: 'id',           // อัปเดตถ้า id ซ้ำ
      ignoreDuplicates: false,    // เพื่อให้ update display_name ด้วย
    );
  }

  // ─── PRODUCTS ───────────────────────────────────────────

  /// ดึงสินค้าทั้งหมด (filter by category ได้)
  static Future<List<Map<String, dynamic>>> getProducts({String? category}) async {
    var query = supabase
        .from('products')
        .select()
        .eq('status', 'Active')
        .order('created_at', ascending: false);

    if (category != null && category != 'all') {
      query = supabase
          .from('products')
          .select()
          .eq('status', 'Active')
          .eq('category', category)
          .order('created_at', ascending: false);
    }

    final res = await query;
    return List<Map<String, dynamic>>.from(res);
  }

  /// ค้นหาสินค้า
  static Future<List<Map<String, dynamic>>> searchProducts(
    String keyword, {
    String? category,
  }) async {
    var query = supabase
        .from('products')
        .select()
        .eq('status', 'Active')
        .ilike('name', '%$keyword%')
        .order('created_at', ascending: false);

    if (category != null && category != 'all') {
      query = supabase
          .from('products')
          .select()
          .eq('status', 'Active')
          .eq('category', category)
          .ilike('name', '%$keyword%')
          .order('created_at', ascending: false);
    }

    final res = await query;
    return List<Map<String, dynamic>>.from(res);
  }

  /// ดึงสินค้าของ seller คนนี้
  static Future<List<Map<String, dynamic>>> getMyProducts() async {
    if (currentUserId == null) return [];
    final res = await supabase
        .from('products')
        .select()
        .eq('seller_id', currentUserId!)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// เพิ่มสินค้า
  static Future<void> addProduct(Map<String, dynamic> data) async {
    final profile = await getProfile();
    await supabase.from('products').insert({
      'seller_id': currentUserId!,
      'seller_name': profile?['display_name'] ?? 'Unknown Shop',
      ...data,
    });
  }

  /// ลบสินค้า
  static Future<void> deleteProduct(String productId) async {
    await supabase.from('products').delete().eq('id', productId);
  }

  /// อัปเดตสถานะสินค้าเป็น Sold
  static Future<void> markProductSold(String productId) async {
    await supabase
        .from('products')
        .update({'status': 'Sold'}).eq('id', productId);
  }

  // ─── PURCHASES ──────────────────────────────────────────

  /// ดึงประวัติการซื้อของ buyer
  static Future<List<Map<String, dynamic>>> getMyPurchases() async {
    if (currentUserId == null) return [];
    final res = await supabase
        .from('purchases')
        .select()
        .eq('buyer_id', currentUserId!)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// ซื้อสินค้า
  static Future<void> buyProduct({
    required Map<String, dynamic> product,
    required String buyerName,
    required String buyerAddress,
    required String buyerPhone,
  }) async {
    // 1. บันทึก purchase
    await supabase.from('purchases').insert({
      'buyer_id': currentUserId!,
      'buyer_name': buyerName,
      'buyer_address': buyerAddress,
      'buyer_phone': buyerPhone,
      'product_id': product['id'],
      'product_name': product['name'],
      'seller_name': product['seller_name'] ?? '',
      'size': product['size'] ?? '',
      'price': product['price'],
      'status': 'On Delivery',
    });
    // 2. mark สินค้าเป็น Sold
    await markProductSold(product['id']);
    // 3. เพิ่ม eco_xp ให้ buyer
    try {
      await supabase.rpc('increment_eco_xp', params: {'user_id': currentUserId!});
    } catch (_) {
      // ไม่ block ถ้า RPC ยังไม่ถูกสร้าง
    }
  }

  // ─── ECO ────────────────────────────────────────────────

  /// นับจำนวนสินค้าที่ซื้อ (eco impact)
  static Future<int> getBuyCount() async {
    if (currentUserId == null) return 0;
    final res = await supabase
        .from('purchases')
        .select()
        .eq('buyer_id', currentUserId!);
    return (res as List).length;
  }
}