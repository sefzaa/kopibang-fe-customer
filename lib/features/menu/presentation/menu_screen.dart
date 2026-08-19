import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/global_header.dart';
import '../logic/menu_cubit.dart';
import '../logic/menu_state.dart';
import 'add_edit_menu_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final Color primaryBrown = const Color(0xFF3C2A21);
  final Color bgColor = const Color(0xFFFAF8F5);

  @override
  void initState() {
    super.initState();
    context.read<MenuCubit>().fetchMenus();
  }

  void _showMenuOptions(BuildContext context, Map<String, dynamic> menu) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final isActive = menu['is_active'] ?? true;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                title: const Text('Edit Menu'),
                onTap: () {
                  Navigator.pop(ctx);
                  final menuCubit = context.read<MenuCubit>();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: menuCubit, child: AddEditMenuScreen(menuData: menu))));
                },
              ),
              ListTile(
                leading: Icon(isActive ? Icons.archive_outlined : Icons.unarchive_outlined, color: Colors.orange),
                title: Text(isActive ? 'Archive Menu' : 'Unarchive Menu'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<MenuCubit>().toggleStatus(menu['id']);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Menu', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<MenuCubit>().deleteMenu(menu['id']);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }


  void _showMenuDetailSheet(BuildContext context, Map<String, dynamic> menu) {
    final List<dynamic>? imageUrls = menu['image_urls'];
    final String? firstImage = (imageUrls != null && imageUrls.isNotEmpty) ? imageUrls.first.toString() : null;
    final List<dynamic> ingredients = menu['ingredients'] ?? [];
    final isActive = menu['is_active'] ?? true;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Agar bottom sheet bisa tinggi dan scrollable
        backgroundColor: bgColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) {
          return ConstrainedBox(
            // Membatasi tinggi maksimal bottom sheet sekitar 85% dari layar HP
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- FOTO MENU BESAR ---
                        if (firstImage != null && firstImage.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(firstImage, width: double.infinity, height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: double.infinity, height: 220, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.broken_image, size: 64, color: Colors.grey))),
                          )
                        else
                          Container(
                            width: double.infinity, height: 220,
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                          ),
                        const SizedBox(height: 24),

                        // --- NAMA & HARGA ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                menu['name'] ?? 'Unknown',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBrown),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '₽${menu['price']}',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBrown),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // --- STATUS & VOLUME ---
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Archived',
                                style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (menu['volume'] != null && menu['volume'].toString().isNotEmpty)
                              Text('•  ${menu['volume']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- DESKRIPSI ---
                        if (menu['description'] != null && menu['description'].toString().isNotEmpty) ...[
                          const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(menu['description'], style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                          const SizedBox(height: 24),
                        ],

                        // --- INGREDIENTS ---
                        if (ingredients.isNotEmpty) ...[
                          const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200)
                            ),
                            child: Column(
                              children: ingredients.map((ing) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('• ${ing['name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(ing['grammage'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        heroTag: const AlwaysStoppedAnimation('menu_fab'),
        onPressed: () {
          final menuCubit = context.read<MenuCubit>();
          Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: menuCubit, child: AddEditMenuScreen())));
        },
        backgroundColor: primaryBrown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GlobalHeader(
                title: 'Menu',
                onProfileTap: () => context.push('/profile'),
              ),
            ),
            Expanded(
              child: BlocConsumer<MenuCubit, MenuState>(
                listener: (context, state) {
                  if (state is MenuActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                  } else if (state is MenuError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
                  }
                },
                builder: (context, state) {
                  if (state is MenuLoading) return const Center(child: CircularProgressIndicator());
                  if (state is MenuLoaded) {
                    final menus = state.menus;
                    if (menus.isEmpty) return const Center(child: Text("Belum ada menu."));

                    return GridView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 16, mainAxisSpacing: 16),
                      itemCount: menus.length,
                      itemBuilder: (context, index) {
                        final menu = menus[index];
                        final price = menu['price'] ?? 0;
                        final isActive = menu['is_active'] ?? true;
                        final List<dynamic>? imageUrls = menu['image_urls'];
                        final String? firstImage = (imageUrls != null && imageUrls.isNotEmpty) ? imageUrls.first.toString() : null;

                        return GestureDetector(
                          // Tap sekali untuk melihat detail lengkap menu
                          onTap: () => _showMenuDetailSheet(context, menu),
                          // Tekan lama tetap berfungsi untuk opsi Edit/Delete
                          onLongPress: () => _showMenuOptions(context, menu),
                          child: Opacity(
                            opacity: isActive ? 1.0 : 0.5,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: firstImage != null && firstImage.isNotEmpty
                                            ? Image.network(firstImage, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)))
                                            : const Icon(Icons.image_not_supported, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(menu['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        // 👇 TAMBAHKAN TAMPILAN VOLUME DI SINI 👇
                                        if (menu['volume'] != null && menu['volume'].toString().isNotEmpty) ...[
                                          Text(
                                            menu['volume'],
                                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                        Text(menu['description'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Text('₽$price', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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