import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Buka komentar ini nanti saat rute sudah siap
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State untuk menyembunyikan/menampilkan password
  bool _obscurePassword = true;

  // Warna utama yang kamu minta
  final Color primaryBrown = const Color(0xFF3C2A21);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna latar belakang krem/off-white agar mirip dengan desain
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              } else if (state is AuthAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Welcome back, Admin!'), backgroundColor: Colors.green),
                );
                // Navigasi ke Dashboard dan lempar Access Token!
                context.go('/dashboard', extra: state.accessToken);
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      children: [
                        Icon(Icons.coffee_outlined, color: primaryBrown, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'KopiBang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBrown,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300, // Placeholder profil bulat
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    // --- TITLE & SUBTITLE ---
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find your focus over a virtual cup.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- EMAIL / USERNAME FIELD ---
                    Text(
                      'Username, WhatsApp, or Email',
                      style: TextStyle(fontSize: 14, color: primaryBrown),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'your@zenith.com',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        suffixIcon: Icon(Icons.alternate_email, color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryBrown),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => value!.isEmpty ? 'Field ini tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),

                    // --- PASSWORD FIELD ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(fontSize: 14, color: primaryBrown),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Fitur Forgot Password (Opsional jika Admin butuh)
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryBrown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '........',
                        hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 4),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryBrown),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 32),

                    // --- SIGN IN BUTTON ---
                    ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          // Memanggil fungsi login dari Cubit
                          context.read<AuthCubit>().login(
                            _emailController.text,
                            _passwordController.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown, // Menggunakan kode warna #3c2a21
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state is AuthLoading)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          else ...[
                            const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- DIVIDER LINE ---
                    Divider(color: Colors.grey.shade300, thickness: 1),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}