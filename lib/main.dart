import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

// Core
import 'core/widgets/main_wrapper.dart';

// Features - Auth & Profile (Mengikuti struktur folder di screenshotmu)
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/profile_repository.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/logic/profile_cubit.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/forgot_pw_screen.dart';
import 'features/auth/presentation/profile_screen.dart';

// Features - Dashboard
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/logic/dashboard_cubit.dart';
import 'features/dashboard/presentation/home_screen.dart';

import 'features/history/data/history_repository.dart'; // import di atas
import 'features/history/logic/history_cubit.dart'; // import di atas
import 'features/history/presentation/history_screen.dart'; // import di atas


import 'features/menu/data/menu_repository.dart';
import 'features/menu/logic/menu_cubit.dart';
import 'features/menu/presentation/menu_screen.dart';

import 'features/dashboard/presentation/scanner_screen.dart';

void main() async {
  // Pastikan binding inisialisasi Flutter sudah berjalan sebelum load dotenv
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables dari .env
  await dotenv.load(fileName: ".env");

  // Inisialisasi format tanggal (opsional jika pakai intl)
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiRepositoryProvider untuk Data Layer
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ProfileRepository()),
        RepositoryProvider(create: (context) => DashboardRepository()),
        RepositoryProvider(create: (context) => HistoryRepository()),
        RepositoryProvider(create: (context) => MenuRepository()),
      ],
      // MultiBlocProvider untuk Logic Layer
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              repository: context.read<ProfileRepository>(),
            )..fetchProfile(), // Langsung fetch data user setelah di-build
          ),
          BlocProvider(
            create: (context) => DashboardCubit(
              repository: context.read<DashboardRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => HistoryCubit(
              repository: context.read<HistoryRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => MenuCubit(
              repository: context.read<MenuRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: '111 Coffee Customer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E2723)),
            useMaterial3: true,
            fontFamily: 'Inter', // Sesuaikan font-nya
          ),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

// Global Key untuk navigasi GoRouter
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Router Konfigurasi
final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login', // Nanti bisa dipindah ke splash screen
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const ScannerScreen(),
    ),

    // StatefulShellRoute untuk membungkus halaman dengan Navbar di MainWrapper
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Menu (Placeholder kosong sementara)
// Tab 1: Menu
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuScreen(),
            ),
          ],
        ),
        // Tab 2: History (Placeholder kosong sementara)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(), // GANTI BAGIAN INI
            ),
          ],
        ),
        // Tab 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);