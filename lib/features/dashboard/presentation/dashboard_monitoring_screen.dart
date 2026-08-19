import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../logic/dashboard_cubit.dart';
import '../logic/dashboard_state.dart';

class DashboardMonitoringScreen extends StatefulWidget {
  const DashboardMonitoringScreen({super.key});

  @override
  State<DashboardMonitoringScreen> createState() => _DashboardMonitoringScreenState();
}

class _DashboardMonitoringScreenState extends State<DashboardMonitoringScreen> {
  final Color primaryBrown = const Color(0xFF3C2A21);
  final Color bgColor = const Color(0xFFFAF8F5);

  // Default filter saat halaman pertama kali dibuka
  String _selectedFilter = 'today';

  // Daftar filter sesuai dokumentasi API (tanpa custom agar UI simpel dlu)
  final List<String> _filters = [
    'today',
    'yesterday',
    'this_week',
    'this_month',
    'this_year'
  ];

  @override
  void initState() {
    super.initState();
    // Fetch data pertama kali berdasarkan _selectedFilter
    context.read<DashboardCubit>().fetchDashboard(filter: _selectedFilter);
  }

  void _onFilterChanged(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
    });
    context.read<DashboardCubit>().fetchDashboard(filter: newFilter);
  }

  // Helper untuk format teks filter agar lebih rapi (misal: 'this_week' jadi 'This Week')
  String _formatFilterName(String filter) {
    return filter.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Monitoring Dashboard', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: primaryBrown,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Time Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // --- 1. FILTER CHIPS ---
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(_formatFilterName(filter)),
                      selected: isSelected,
                      selectedColor: primaryBrown,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : primaryBrown,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) _onFilterChanged(filter);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // --- 2. TAMPILAN LOADING / ERROR / DATA ---
                if (state is DashboardLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                else if (state is DashboardError)
                  Center(child: Text(state.message, style: const TextStyle(color: Colors.red)))
                else if (state is DashboardLoaded)
                    _buildContent(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. TOTAL CARD (Sesuai Filter) ---
        Row(
          children: [
            Expanded(child: _buildStatCard(title: 'TOTAL SALES', value: '₽${state.totalSales}', icon: Icons.payments_outlined)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(title: 'TOTAL ORDERS', value: '${state.totalOrders}', icon: Icons.receipt_long_outlined)),
          ],
        ),
        const SizedBox(height: 40),

        // --- 2. BAR CHART UNTUK MENU TERLARIS ---
        Text('Top Selling Menus (${_formatFilterName(_selectedFilter)})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        state.menuStats.isEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('No menu sales in this period')),
        )
            : Column(
          children: [
            // --- CHART CONTAINER ---
            Container(
              height: 280,
              padding: const EdgeInsets.only(top: 24, right: 24, left: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(state.menuStats),
                  // Tooltip tetap dipertahankan agar informatif saat ditekan
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final productName = state.menuStats[group.x.toInt()]['product_name'] ?? 'Unknown';
                        return BarTooltipItem(
                          '$productName\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} terjual',
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.normal),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= state.menuStats.length) return const SizedBox.shrink();

                          // Label menggunakan format #1, #2, dst.
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBrown
                                )
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateBarGroups(state.menuStats),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. LEGEND / KETERANGAN MENU ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Legend', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...state.menuStats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final productName = entry.value['product_name'] ?? 'Unknown';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                                '#${index + 1}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown, fontSize: 14)
                            ),
                          ),
                          Expanded(
                              child: Text(
                                  productName.toString(),
                                  style: const TextStyle(fontSize: 14)
                              )
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget helper untuk UI Card
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
              Expanded(child: Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600))),
              Icon(icon, color: primaryBrown, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: primaryBrown, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Logika untuk menentukan tinggi maksimal Y Axis pada chart
  double _getMaxY(List<dynamic> stats) {
    if (stats.isEmpty) return 10;
    double max = 0;
    for (var item in stats) {
      final sold = (item['total_sold'] ?? 0).toDouble();
      if (sold > max) max = sold;
    }
    return max + (max * 0.2); // Tambah 20% ruang kosong di atas chart
  }

  // Mapping data API (menu_stats) menjadi format Bar Chart
  List<BarChartGroupData> _generateBarGroups(List<dynamic> stats) {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < stats.length; i++) {
      final totalSold = (stats[i]['total_sold'] ?? 0).toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalSold,
              color: primaryBrown,
              width: 22,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            ),
          ],
        ),
      );
    }
    return groups;
  }
}