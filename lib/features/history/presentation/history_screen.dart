import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/global_header.dart';
import '../logic/history_cubit.dart';
import '../logic/history_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryBrown = const Color(0xFF3C2A21);
  final Color bgColor = const Color(0xFFFAF8F5);

  final ScrollController _scrollController = ScrollController();

  // State untuk menyimpan filter yang dipilih saat ini
  String _selectedFilter = 'this_month';
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchData(isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        // Load page berikutnya dengan filter yang sedang aktif
        _fetchData();
      }
    });
  }

  void _fetchData({bool isRefresh = false}) {
    context.read<HistoryCubit>().fetchHistory(
      isRefresh: isRefresh,
      filter: _selectedFilter,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIKA PERUBAHAN FILTER & KALENDER ---
  Future<void> _onFilterChanged(String? newValue) async {
    if (newValue == null) return;

    if (newValue == 'custom') {
      // Tampilkan kalender rentang waktu jika pilih "Range Tanggal"
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2023), // Batas kalender masa lalu
        lastDate: DateTime.now(), // Batas maksimal kalender
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryBrown,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _selectedFilter = newValue;
          // Format tanggal menjadi YYYY-MM-DD sesuai permintaan backend
          _startDate = DateFormat('yyyy-MM-dd').format(picked.start);
          _endDate = DateFormat('yyyy-MM-dd').format(picked.end);
        });
        _fetchData(isRefresh: true);
      }
    } else {
      // Jika pilih filter selain custom (today, yesterday, dll)
      setState(() {
        _selectedFilter = newValue;
        _startDate = null;
        _endDate = null;
      });
      _fetchData(isRefresh: true);
    }
  }

  void _showOrderDetailSheet(BuildContext context, Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];
    final discount = order['discount'] ?? 0;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('#${order['order_id'].toString().substring(0,8).toUpperCase()}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 24),

                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item['quantity']}x  ${item['product_name'] ?? 'Menu Item'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('₽${item['price_at_time']}'),
                      ],
                    ),
                  );
                }),

                const Divider(height: 32),

                if (discount > 0)
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Discount', style: TextStyle(color: Colors.green)), Text('-₽$discount', style: const TextStyle(color: Colors.green))]),

                if (order['earned_points'] != null && order['earned_points'] > 0)
                  Padding(padding: const EdgeInsets.only(top: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Earned Points', style: TextStyle(color: Colors.orange)), Text('+${order['earned_points']} pts', style: const TextStyle(color: Colors.orange))])),

                const Divider(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Paid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('₽${order['final_amount']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBrown))]),
                const SizedBox(height: 24),
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GlobalHeader(
                title: 'Order History',
                onProfileTap: () => context.push('/profile'),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: primaryBrown,
                onRefresh: () async => _fetchData(isRefresh: true),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER DENGAN DROPDOWN FILTER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Transactions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primaryBrown)),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300)
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                icon: Icon(Icons.filter_list, color: primaryBrown, size: 18),
                                style: TextStyle(color: primaryBrown, fontSize: 12, fontWeight: FontWeight.bold),
                                items: const [
                                  DropdownMenuItem(value: 'today', child: Text('Today')),
                                  DropdownMenuItem(value: 'yesterday', child: Text('Yesterday')),
                                  DropdownMenuItem(value: 'this_week', child: Text('This Week')),
                                  DropdownMenuItem(value: 'this_month', child: Text('This Month')),
                                  DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
                                ],
                                onChanged: _onFilterChanged,
                              ),
                            ),
                          )
                        ],
                      ),

                      // Tampilkan indikator range tanggal yang dipilih jika custom
                      if (_selectedFilter == 'custom' && _startDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Showing: $_startDate to $_endDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),

                      const SizedBox(height: 16),

                      BlocBuilder<HistoryCubit, HistoryState>(
                        builder: (context, state) {
                          if (state is HistoryLoading && state is! HistoryLoaded) {
                            return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                          } else if (state is HistoryError) {
                            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                          } else if (state is HistoryLoaded) {
                            final orders = state.orders;
                            if (orders.isEmpty) {
                              return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 40.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                        const SizedBox(height: 16),
                                        const Text("No transactions found.", style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  )
                              );
                            }

                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    final parsedDate = DateTime.parse(order['created_at']).toLocal();
                                    final dateString = DateFormat("MMM dd, yyyy • hh:mm a").format(parsedDate);

                                    final items = order['items'] as List<dynamic>? ?? [];
                                    int totalItems = 0;
                                    for (var item in items) { totalItems += (item['quantity'] as int? ?? 1); }

                                    return GestureDetector(
                                      onLongPress: () => _showOrderDetailSheet(context, order),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFFAF8F5), shape: BoxShape.circle), child: Icon(Icons.receipt_long, color: primaryBrown)),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(dateString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                  const SizedBox(height: 4),
                                                  Text('$totalItems Items', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            Text('₽${order['final_amount']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBrown)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (!state.hasReachedMax)
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator()),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}