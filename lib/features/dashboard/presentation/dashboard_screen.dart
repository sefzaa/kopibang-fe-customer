import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

// Import widget global
import '../../../core/widgets/global_header.dart';
import '../../../main.dart';

// Import Cubit
import '../logic/dashboard_cubit.dart';
import '../logic/dashboard_state.dart';
import '../../history/logic/history_cubit.dart';
import '../../history/logic/history_state.dart';

// Import Screens untuk Bottom Nav & Scanner
import '../../menu/presentation/menu_screen.dart';
import '../../menu/logic/menu_cubit.dart';
import '../../stock/presentation/stock_screen.dart';
import '../../stock/logic/stock_cubit.dart';
import '../../history/presentation/history_screen.dart';
import '../../transaction/presentation/scanner_screen.dart';
import '../../transaction/presentation/transaction_screen.dart';
import '../../transaction/logic/transaction_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryBrown = const Color(0xFF3C2A21);
  final Color bgColor = const Color(0xFFFAF8F5);

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    context.read<DashboardCubit>().fetchDashboard(filter: 'this_month');
    context.read<HistoryCubit>().fetchHistory(limit: 5);
  }

  Future<void> _handleRedeemScan() async {
    final scannedToken = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );

    if (scannedToken != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<TransactionCubit>()),
              BlocProvider(create: (_) => getIt<MenuCubit>()),
            ],
            child: TransactionScreen(initialRedeemToken: scannedToken),
          ),
        ),
      );
    }
  }

  Widget get _currentTab {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return BlocProvider(create: (_) => getIt<MenuCubit>(), child: const MenuScreen());
      case 2:
        return BlocProvider(create: (_) => getIt<HistoryCubit>(), child: const HistoryScreen());
      case 3:
        return BlocProvider(create: (_) => getIt<StockCubit>(), child: const StockScreen());
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        heroTag: const AlwaysStoppedAnimation('dashboard_fab'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => getIt<TransactionCubit>()),
                  BlocProvider(create: (_) => getIt<MenuCubit>()),
                ],
                child: const TransactionScreen(),
              ),
            ),
          );
        },
        backgroundColor: primaryBrown,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: EdgeInsets.zero,
        // Dibuat lebih dinamis agar tidak overflow
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(icon: Icons.home_filled, label: 'Home', index: 0),
                    _buildNavItem(icon: Icons.coffee_outlined, label: 'Menu', index: 1),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Ruang untuk FAB di tengah
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(icon: Icons.history, label: 'History', index: 2),
                    _buildNavItem(icon: Icons.inventory_2_outlined, label: 'Stock', index: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _currentTab,
    );
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: RefreshIndicator(
        color: primaryBrown,
        onRefresh: () async {
          _loadAllData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalHeader(
                onProfileTap: () {
                  context.push('/profile');
                },
              ),
              const SizedBox(height: 32),

              Text('This Month Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primaryBrown)),
              const SizedBox(height: 4),
              Text(
                "Here is your store performance for the current month.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 24),

              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                  } else if (state is DashboardError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                      child: Text(state.message, style: const TextStyle(color: Colors.red)),
                    );
                  } else if (state is DashboardLoaded) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Trigger navigasi ke halaman baru
                            context.push('/monitoring-dashboard');
                          },
                          child: Row(
                            children: [
                              Expanded(child: _buildStatCard(title: 'SALES', value: '₽${state.totalSales}', icon: Icons.payments_outlined)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard(title: 'ORDERS', value: '${state.totalOrders}', icon: Icons.receipt_long_outlined)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _handleRedeemScan,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A110A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('REDEEM POINTS', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Scan Customer QR', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Tap here to scan and apply rewards', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text('Recent Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBrown)),
              const SizedBox(height: 16),

              BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HistoryLoaded) {
                    final recentOrders = state.orders.take(3).toList();
                    if (recentOrders.isEmpty) {
                      return const Text("No recent orders found.");
                    }
                    return Column(
                      children: recentOrders.map((order) {
                        final parsedDate = DateTime.parse(order['created_at']).toLocal();
                        final dateString = DateFormat("MMM dd, yyyy • hh:mm a").format(parsedDate);

                        final items = order['items'] as List<dynamic>? ?? [];
                        int totalItems = 0;
                        for (var item in items) {
                          totalItems += (item['quantity'] as int? ?? 1);
                        }

                        return _buildRecentOrderCard(
                          itemName: '$totalItems Items',
                          date: dateString,
                          price: '₽${order['final_amount']}',
                          points: '+${order['earned_points'] ?? 0} pts',
                          icon: Icons.receipt_long_outlined,
                          iconBgColor: const Color(0xFFE5E0D8),
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Kunci agar tidak overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryBrown : Colors.grey.shade400, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryBrown : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
              Icon(icon, color: Colors.grey.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: primaryBrown, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentOrderCard({required String itemName, required String date, required String price, required String points, required IconData icon, required Color iconBgColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: primaryBrown, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryBrown)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryBrown)),
              const SizedBox(height: 4),
              Text(points, style: TextStyle(fontSize: 12, color: Colors.green.shade600, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}