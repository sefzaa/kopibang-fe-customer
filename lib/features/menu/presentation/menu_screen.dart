import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopibang_customer/core/widgets/global_header.dart';
import '../logic/menu_cubit.dart';
import '../logic/menu_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MenuCubit>().fetchMenus();
  }

  // --- Fungsi untuk memunculkan Bottom Sheet Detail Menu ---
  void _showMenuDetail(BuildContext context, Map<String, dynamic> menu) {
    final List<dynamic> imageUrls = menu['image_urls'] ?? [];
    final String? imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;

    final int originalPrice = menu['price'] ?? 0;
    final int finalPrice = menu['final_price'] ?? originalPrice;
    final bool hasDiscount = finalPrice < originalPrice;

    final String description = menu['description'] ?? 'Belum ada deskripsi untuk menu ini.';
    final List<dynamic> ingredients = menu['ingredients'] ?? [];

    final String voucherCode = menu['voucher_code'] ?? '';
    final int voucherDiscount = menu['voucher_discount'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFFAF8F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Gambar Header Besar
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(imageUrl, height: 300, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildImagePlaceholder(height: 300))
                        : _buildImagePlaceholder(height: 300),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Info Utama (Nama, Volume, Harga)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(menu['name'] ?? 'Menu', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF3EEE8), borderRadius: BorderRadius.circular(8)),
                                  child: Text(menu['volume'] ?? 'Reguler', style: const TextStyle(fontSize: 12, color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasDiscount)
                                Text('RUB $originalPrice', style: const TextStyle(fontSize: 14, color: Colors.red, decoration: TextDecoration.lineThrough)),
                              Text('RUB $finalPrice', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. Info Voucher Khusus Menu (Jika Ada)
                      if (voucherCode.isNotEmpty && voucherDiscount > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                          child: Row(
                            children: [
                              const Icon(Icons.local_offer, color: Colors.green, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Promo Spesial! Gunakan kode "$voucherCode" untuk ekstra potongan Rp $voucherDiscount.', style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),

                      // 4. Deskripsi
                      const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                      const SizedBox(height: 8),
                      Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
                      const SizedBox(height: 24),

                      // 5. Komposisi (Ingredients)
                      const Text('Komposisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                      const SizedBox(height: 12),
                      ingredients.isEmpty
                          ? const Text('Rahasia dapur Barista 🤫', style: TextStyle(fontSize: 14, color: Colors.black54, fontStyle: FontStyle.italic))
                          : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ingredients.map((ing) {
                          final String ingName = ing['name'] ?? '';
                          final String ingGrammage = ing['grammage'] ?? '';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.eco_outlined, size: 14, color: Colors.green),
                                const SizedBox(width: 6),
                                Text('$ingName ($ingGrammage)', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 100), // Spacing untuk tombol bawah
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder({double height = 150}) {
    return Container(
      height: height,
      color: const Color(0xFFF3EEE8),
      child: const Center(
        child: Icon(Icons.coffee, color: Color(0xFFD7CCC8), size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: GlobalHeader(
                title: 'Our Menu',
                subtitle: 'Discover your next favorite brew.',
              ),
            ),
            Expanded(
              child: BlocBuilder<MenuCubit, MenuState>(
                builder: (context, state) {
                  if (state is MenuInitial || state is MenuLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3E2723)));
                  } else if (state is MenuError) {
                    return Center(child: Text('Terjadi kesalahan: ${state.message}', style: const TextStyle(color: Colors.red)));
                  } else if (state is MenuLoaded) {
                    final menus = state.menus;

                    if (menus.isEmpty) {
                      return const Center(child: Text('Menu belum tersedia saat ini.', style: TextStyle(color: Colors.black54)));
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF3E2723),
                      onRefresh: () async {
                        await context.read<MenuCubit>().fetchMenus();
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final menu = menus[index];

                          final List<dynamic> imageUrls = menu['image_urls'] ?? [];
                          final String? imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;
                          final int originalPrice = menu['price'] ?? 0;
                          final int finalPrice = menu['final_price'] ?? originalPrice;
                          final bool hasDiscount = finalPrice < originalPrice;

                          // --- GestureDetector untuk memicu Bottom Sheet ---
                          return GestureDetector(
                            onTap: () => _showMenuDetail(context, menu),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: imageUrl != null && imageUrl.isNotEmpty
                                          ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildImagePlaceholder())
                                          : _buildImagePlaceholder(),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                menu['name'] ?? 'Menu',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C3E50)),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(menu['volume'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (hasDiscount)
                                                Text('RUB $originalPrice', style: const TextStyle(fontSize: 11, color: Colors.red, decoration: TextDecoration.lineThrough)),
                                              Text('RUB $finalPrice', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2723))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}