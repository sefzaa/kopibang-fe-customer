import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import '../logic/profile_cubit.dart';
import '../logic/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryBrown = const Color(0xFF3C2A21);

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadAllData();
  }

  void _showVoucherManagementSheet() {
    final profileCubit = context.read<ProfileCubit>();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return BlocProvider.value(
            value: profileCubit,
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Manage Vouchers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBrown)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddEditVoucherSheet(); // Panggil fungsi tanpa parameter = Create
                          },
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text('New', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoaded) {
                          final vouchers = state.vouchers;
                          if (vouchers.isEmpty) {
                            return const Center(child: Text("No active vouchers."));
                          }
                          return ListView.builder(
                            itemCount: vouchers.length,
                            itemBuilder: (context, index) {
                              final v = vouchers[index];

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                                  child: const Icon(Icons.local_offer_outlined, color: Colors.orange),
                                ),
                                title: Text(v['code'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                subtitle: Text('Discount: ₽${v['discount_amount']} | Type: ${v['type']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // TOMBOL EDIT
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _showAddEditVoucherSheet(existingVoucher: v); // Panggil fungsi dengan parameter = Edit
                                      },
                                    ),
                                    // TOMBOL DELETE
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => profileCubit.deleteVoucher(v['id'].toString()),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  // FUNGSI GABUNGAN: CREATE & EDIT
  void _showAddEditVoucherSheet({Map<String, dynamic>? existingVoucher}) {
    final profileCubit = context.read<ProfileCubit>();
    final isEdit = existingVoucher != null;

    // Inisialisasi default value (Kosong jika Create, Terisi jika Edit)
    final codeCtrl = TextEditingController(text: isEdit ? existingVoucher['code'] : '');
    final discCtrl = TextEditingController(text: isEdit ? existingVoucher['discount_amount'].toString() : '');
    final minPurchaseCtrl = TextEditingController(text: isEdit ? existingVoucher['min_purchase'].toString() : '0');

    String voucherType = isEdit ? existingVoucher['type'] : 'cart_discount';
    DateTime startDate = isEdit ? DateTime.parse(existingVoucher['start_date']) : DateTime.now();
    DateTime endDate = isEdit ? DateTime.parse(existingVoucher['end_date']) : DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return BlocProvider.value(
            value: profileCubit,
            child: StatefulBuilder(
                builder: (contextBottomSheet, setModalState) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(contextBottomSheet).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Promo Voucher' : 'Create Promo Voucher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBrown)),
                        const SizedBox(height: 16),
                        TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Voucher Code (e.g. PROMO20)')),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(child: TextField(controller: discCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount (₽)'))),
                            const SizedBox(width: 12),
                            Expanded(child: TextField(controller: minPurchaseCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Purchase'))),
                          ],
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: voucherType,
                          decoration: const InputDecoration(labelText: 'Voucher Type'),
                          items: const [
                            DropdownMenuItem(value: 'cart_discount', child: Text('Cart Discount')),
                            DropdownMenuItem(value: 'menu_promo', child: Text('Menu Promo')),
                          ],
                          onChanged: (val) => setModalState(() => voucherType = val!),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(context: contextBottomSheet, initialDate: startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                                  if (date != null) setModalState(() => startDate = date);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Start Date', border: InputBorder.none),
                                  child: Text(startDate.toIso8601String().split('T')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(context: contextBottomSheet, initialDate: endDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                                  if (date != null) setModalState(() => endDate = date);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'End Date', border: InputBorder.none),
                                  child: Text(endDate.toIso8601String().split('T')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryBrown, padding: const EdgeInsets.symmetric(vertical: 16)),
                            onPressed: () {
                              if (codeCtrl.text.isNotEmpty && discCtrl.text.isNotEmpty) {
                                final payload = {
                                  "code": codeCtrl.text,
                                  "discount_amount": int.tryParse(discCtrl.text) ?? 0,
                                  "min_purchase": int.tryParse(minPurchaseCtrl.text) ?? 0,
                                  "type": voucherType,
                                  "start_date": startDate.toIso8601String().split('T')[0],
                                  "end_date": endDate.toIso8601String().split('T')[0],
                                  "is_active": true, // Tetap aktif secara default
                                };

                                if (isEdit) {
                                  profileCubit.editVoucher(existingVoucher['id'].toString(), payload);
                                } else {
                                  profileCubit.createVoucher(payload);
                                }

                                Navigator.pop(contextBottomSheet);
                                _showVoucherManagementSheet();
                              }
                            },
                            child: Text(isEdit ? 'UPDATE VOUCHER' : 'SAVE VOUCHER', style: const TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBrown),
                        onPressed: () => context.read<ProfileCubit>().loadAllData(),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Try Again', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              );
            }

            if (state is ProfileLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Admin&background=3C2A21&color=fff')),
                    const SizedBox(height: 16),
                    Text(state.profile['name'] ?? 'Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBrown)),
                    Text(state.profile['role'] ?? 'SENIOR BARISTA', style: const TextStyle(letterSpacing: 2, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 32),

                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                      child: SwitchListTile(
                        activeColor: Colors.green,
                        title: const Text('Work Status', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        subtitle: Text(state.isAvailable ? 'Available' : 'Offline', style: TextStyle(color: state.isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                        value: state.isAvailable,
                        onChanged: (val) => context.read<ProfileCubit>().toggleStatus(val),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        leading: Icon(Icons.local_offer_outlined, color: primaryBrown),
                        title: const Text('Manage Vouchers'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showVoucherManagementSheet,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade100)),
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout', style: TextStyle(color: Colors.red)),
                        onTap: () => context.read<AuthCubit>().logout(),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}