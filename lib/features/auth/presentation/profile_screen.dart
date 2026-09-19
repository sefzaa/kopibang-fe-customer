import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../logic/profile_cubit.dart';
import '../logic/profile_state.dart';
import 'package:kopibang_customer/core/widgets/global_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryBrown = const Color(0xFF3E2723);

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();
  }

  // Diubah menjadi Bottom Sheet yang rapi sesuai permintaan
  void _showEditProfileBottomSheet(BuildContext context, Map<String, dynamic> currentData) {
    final TextEditingController nameCtrl = TextEditingController(text: currentData['name']);
    final TextEditingController userCtrl = TextEditingController(text: currentData['username']);

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
            const Text('Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 4),
            const Text('Manage your personal info and security', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: userCtrl,
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.read<ProfileCubit>().updateProfile(nameCtrl.text.trim(), userCtrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
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
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            } else if (state is ProfileLoggedOut) {
              context.go('/login');
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF3E2723)));

            if (state is ProfileLoaded) {
              final user = state.profileData;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    const GlobalHeader(title: '', subtitle: ''),

                    // Avatar & Nama
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150'),
                              ),
                              GestureDetector(
                                onTap: () => _showEditProfileBottomSheet(context, user),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Color(0xFF3E2723), shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(user['name'] ?? '-', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text('@${user['username'] ?? '-'}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Points Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3B32),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('POINTS BALANCE', style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text('${user['points'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Settings List (Dibungkus dengan Material untuk Mencegah Error ListTile & DecoratedBox)
                    const Align(alignment: Alignment.centerLeft, child: Text('Settings & Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200)
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person_outline, color: Colors.black87)),
                              title: const Text('Account Details'),
                              subtitle: const Text('Manage your personal info', style: TextStyle(fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                              onTap: () => _showEditProfileBottomSheet(context, user),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.help_outline, color: Colors.black87)),
                              title: const Text('Help & Support'),
                              subtitle: const Text('FAQs, contact us, and legal', style: TextStyle(fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign Out Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.read<ProfileCubit>().logout(),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    const Text('App Version 1.0.0+1', style: TextStyle(color: Colors.black45, fontSize: 12)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}