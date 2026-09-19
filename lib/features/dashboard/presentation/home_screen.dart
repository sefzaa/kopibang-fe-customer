import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kopibang_customer/core/widgets/global_header.dart';
import '../../auth/logic/profile_cubit.dart';
import '../../auth/logic/profile_state.dart';
import '../logic/dashboard_cubit.dart';
import '../logic/dashboard_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();
    context.read<DashboardCubit>().loadDashboardData();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPreOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: const Color(0xFFFAF8F5),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pre Order via:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.chat, color: Colors.green),
              ),
              title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('081365639689'),
              onTap: () => _launchURL('https://wa.me/6281365639689?text=Halo%20111%20Coffee,%20saya%20ingin%20Pre%20Order'),
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.blue),
              ),
              title: const Text('Telegram', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('081365639689'),
              onTap: () => _launchURL('https://t.me/6281365639689'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemQRDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF3E2723))),
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    try {
      final token = await context.read<DashboardCubit>().requestRedeemQr();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (token != null && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white, // Background lebih terang / putih bersih
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Tunjukkan QR ke Barista', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 250,
              height: 250,
              child: Center(
                child: QrImageView(data: token, version: QrVersions.auto, size: 220),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<ProfileCubit>().fetchProfile();
                  },
                  child: const Text('Selesai', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileCubit>().fetchProfile();
            await context.read<DashboardCubit>().loadDashboardData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PERBAIKAN: Mengganti GlobalHeader dengan baris logo yang lebih ringkas
                const Row(
                  children: [
                    Icon(Icons.coffee_outlined, color: Color(0xFF3E2723), size: 20),
                    SizedBox(width: 8),
                    Text(
                      '111 Coffee',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
                // Jarak yang lebih rapat
                const SizedBox(height: 24),

                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    String name = 'Guest';
                    if (state is ProfileLoaded) name = state.profileData['name'] ?? 'Guest';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DIGITAL SANCTUARY', style: TextStyle(color: Colors.black54, fontSize: 10, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text('Good Morning, $name.', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                        const SizedBox(height: 4),
                        const Text('Your morning ritual is ready to be brewed. Enjoy the silence of the early hours.', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Promo Banner Dummy
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1497935586351-b67a49e012bf?auto=format&fit=crop&q=80'),
                      fit: BoxFit.cover,
                      opacity: 0.6,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('LIMITED TIME OFFER', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 8),
                        Text('20% Off Your Next Brew.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Points & Redeem
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    int points = 0;
                    if (state is ProfileLoaded) points = state.profileData['points'] ?? 0;
                    final bool canRedeem = points >= 100;
                    final double progress = (points / 100).clamp(0.0, 1.0);

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFF3EEE8), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('POINTS PROGRESS', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(text: '$points', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                        const TextSpan(text: ' / 100 pts', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: canRedeem ? () => _showRedeemQRDialog(context) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3E2723),
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Redeem', style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white,
                            color: const Color(0xFF3E2723),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 8),
                          Text(canRedeem ? 'Kamu bisa redeem sekarang!' : '${100 - points} more points until your next ritual on us.', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Barista Status & Riwayat Order
                BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) return const Center(child: CircularProgressIndicator());
                    if (state is DashboardLoaded) {
                      final bool isAvailable = state.baristaStatus['is_available'] ?? false;
                      final List orders = state.recentOrders;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Barista Availability Card (Tanpa nama spesifik, pakai gambar mockup)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFF3EEE8), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('BARISTA AVAILABILITY', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text(isAvailable ? 'Ready to craft your coffee' : 'Currently Offline', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.circle, size: 12, color: isAvailable ? Colors.green : Colors.red),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tombol Pre-Order dengan ikon chat/pesan (bukan petir)
                          ElevatedButton.icon(
                            onPressed: () => _showPreOrderSheet(context),
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.amberAccent),
                            label: const Text('Pre Order via WA / Telegram', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C3E50),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 32),

                          const Text('Recent Rituals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          orders.isEmpty
                              ? const Text('Belum ada pesanan.', style: TextStyle(color: Colors.black54))
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final String itemName = (order['items'] != null && order['items'].isNotEmpty)
                                  ? order['items'][0]['product_name']
                                  : 'Pesanan';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(color: Color(0xFFF3EEE8), shape: BoxShape.circle),
                                      child: const Icon(Icons.coffee, color: Color(0xFF3E2723), size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Total: RUB ${order['final_amount']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    Text('+${order['earned_points'] ?? 0} pts', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                          ),

                          if (orders.isNotEmpty)
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context.go('/history');
                                },
                                child: const Text('All history orders', style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline)),
                              ),
                            ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}