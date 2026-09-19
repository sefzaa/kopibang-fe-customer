import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kopibang_customer/core/widgets/global_header.dart';
import '../logic/history_cubit.dart';
import '../logic/history_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadHistory(isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        context.read<HistoryCubit>().loadHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy • HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // --- Fungsi untuk memunculkan Detail Pesanan ---
  void _showOrderDetailBottomSheet(BuildContext context, dynamic order) {
    final List items = order['items'] ?? [];
    final bool isRedeem = order['is_redeem'] ?? false;
    final String status = order['status'] ?? 'unknown';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF8F5),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Status & Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Detail Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withAlpha(25), // Transparan 10%
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(_formatDate(order['created_at'] ?? ''), style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const Divider(height: 32),

            // Daftar Item yang dipesan
            const Text('Daftar Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...items.map((item) {
              final int qty = item['quantity'] ?? 1;
              final int price = item['price_at_time'] ?? 0;
              final String name = item['product_name'] ?? 'Menu';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${qty}x', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(name, style: const TextStyle(fontSize: 14)),
                    ),
                    Text('Rp ${price * qty}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),

            const Divider(height: 32),

            // Ringkasan Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: Colors.black54)),
                Text('Rp ${order['total_amount'] ?? 0}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diskon', style: TextStyle(color: Colors.black54)),
                Text('- Rp ${order['discount'] ?? 0}', style: const TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Akhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  isRedeem ? 'Free (Redeem)' : 'Rp ${order['final_amount'] ?? 0}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isRedeem ? Colors.orange : const Color(0xFF3E2723)),
                ),
              ],
            ),
            if (!isRedeem) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Poin Didapat', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text('+${order['earned_points'] ?? 0} pts', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2723),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
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
                title: 'Your Rituals',
                subtitle: 'A journey through your favorite brews.',
              ),
            ),
            Expanded(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  List<dynamic> orders = [];
                  bool isFetchingMore = false;

                  if (state is HistoryInitial || (state is HistoryLoading && state.isFirstFetch)) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3E2723)));
                  } else if (state is HistoryError) {
                    return Center(child: Text('Terjadi kesalahan: ${state.message}', style: const TextStyle(color: Colors.red)));
                  }

                  if (state is HistoryLoaded) {
                    orders = state.orders;
                  } else if (state is HistoryLoading) {
                    orders = state.oldOrders;
                    isFetchingMore = true;
                  }

                  if (orders.isEmpty) {
                    return const Center(child: Text('Belum ada riwayat pesanan.', style: TextStyle(color: Colors.black54)));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<HistoryCubit>().loadHistory(isRefresh: true);
                    },
                    color: const Color(0xFF3E2723),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: orders.length + (isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= orders.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator(color: Color(0xFF3E2723))),
                          );
                        }

                        final order = orders[index];
                        final items = order['items'] as List<dynamic>? ?? [];
                        final itemName = items.isNotEmpty ? items[0]['product_name'] : 'Pesanan';
                        final isRedeem = order['is_redeem'] ?? false;
                        final status = order['status'] ?? 'unknown';

                        // --- KARTU DIBUNGKUS GESTURE DETECTOR ---
                        return GestureDetector(
                          onTap: () => _showOrderDetailBottomSheet(context, order),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDate(order['created_at'] ?? ''), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status).withAlpha(25),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                                      ),
                                    )
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(color: Color(0xFFF3EEE8), shape: BoxShape.circle),
                                      child: Icon(isRedeem ? Icons.stars : Icons.coffee, color: const Color(0xFF3E2723), size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          if (items.length > 1)
                                            Text('+ ${items.length - 1} item lainnya', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isRedeem ? 'Free' : 'Rp ${order['final_amount']}',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isRedeem ? Colors.orange : Colors.black),
                                        ),
                                        if (!isRedeem)
                                          Text('+${order['earned_points'] ?? 0} pts', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}