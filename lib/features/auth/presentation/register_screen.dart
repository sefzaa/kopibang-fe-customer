import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kopibang_customer/core/widgets/global_header.dart';
import 'package:kopibang_customer/core/widgets/custom_text_field.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rewritePasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _rewritePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is AuthAuthenticated) {
              // Jika register & auto-login sukses
              context.go('/home');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const GlobalHeader(
                    title: 'Join the Club, Get Perks!',
                    subtitle: 'Fresh Brews Await',
                    centerText: true,
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Information', style: TextStyle(color: Colors.black54)),
                        const Divider(),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'e.g. Julian Vane',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'julian@zenith.coffee',
                        ),

                        const SizedBox(height: 24),
                        const Text('Account Details', style: TextStyle(color: Colors.black54)),
                        const Divider(),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'brewminder_99',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          isPassword: true,
                          suffixIcon: const Icon(Icons.visibility_off, color: Colors.black38),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _rewritePasswordController,
                          label: 'Confirm Password',
                          hint: '••••••••',
                          isPassword: true,
                          suffixIcon: const Icon(Icons.visibility_off, color: Colors.black38),
                        ),

                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                            // Validasi basic sebelum kirim API
                            if (_passwordController.text != _rewritePasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password tidak cocok!'), backgroundColor: Colors.red),
                              );
                              return;
                            }

                            context.read<AuthCubit>().register(
                              name: _nameController.text.trim(),
                              username: _usernameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              rewritePassword: _rewritePasswordController.text.trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E2723),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.pop(), // Kembali ke halaman Login
                            child: RichText(
                              text: const TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: Colors.black54),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}