// lib/main.dart
// ══════════════════════════════════════════════════════════════
//  MindfulMeals — Complete App
//  Phase 1 (UI) + Phase 2 (Go Out) + Phase 3 (Real Backend)
//
//  HOW IT WORKS:
//  1. App starts → AuthGate checks for stored JWT token
//  2. No token → LoginScreen
//  3. Token found → tries to load user from backend
//  4. Backend not running → stays on LoginScreen with error
//  5. Logged in → MainShell with all 5 screens
//
//  The app works with OR without the backend:
//  - Without backend: all screens show, uses mock data
//  - With backend: real AI meals, real posts, real auth
// ══════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'widgets/glass_widgets.dart';

// Auth
import 'screens/auth/login_screen.dart';

// Main screens
import 'screens/home_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/ar_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080F18),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    // ProviderScope is required for Riverpod state management
    const ProviderScope(child: MindfulMealsApp()),
  );
}

class MindfulMealsApp extends StatelessWidget {
  const MindfulMealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindfulMeals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.bgMid,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: const AuthGate(),
    );
  }
}

// ── AUTH GATE ─────────────────────────────────────────────────
// Checks login state and routes to the right screen.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // Checking tokens on startup
    if (auth.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
          const AmbientBlob(alignment: Alignment(-0.8, -0.5), color: AppColors.primary, size: 260),
          const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('🌿', style: TextStyle(fontSize: 56)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ])),
        ]),
      );
    }

    // Not logged in → show login/register screen
    if (!auth.isLoggedIn) return const LoginScreen();

    // Logged in → show full app
    return const MainShell();
  }
}

// ── MAIN SHELL ────────────────────────────────────────────────
// The main app frame with bottom navigation and all 5 screens.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _navItems = [
    (icon: '🏠', label: 'Home'),
    (icon: '📖', label: 'Recipe'),
    (icon: '📱', label: 'AR View'),
    (icon: '👥', label: 'Community'),
    (icon: '🧘', label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  void _navigate(int index) {
    if (index == _currentIndex) return;
    _fadeCtrl.reverse().then((_) {
      setState(() => _currentIndex = index);
      _fadeCtrl.forward();
    });
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0: return HomeScreen(onNavigate: _navigate);
      case 1: return RecipeScreen(onNavigate: _navigate);
      case 2: return ARScreen(onNavigate: _navigate);
      case 3: return const CommunityScreen();
      case 4: return const ProfileScreen();
      default: return HomeScreen(onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bgDark,
      body: Stack(children: [
        // Background
        Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
        const AmbientBlob(alignment: Alignment(-0.8, -0.7), color: AppColors.primary, size: 260),
        const AmbientBlob(alignment: Alignment(0.9, 0.4), color: AppColors.emerald, size: 200),

        // Top bar
        Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

        // Screen content
        Positioned(
          top: MediaQuery.of(context).padding.top + 68,
          left: 0, right: 0,
          bottom: 80,
          child: FadeTransition(opacity: _fadeAnim, child: _buildScreen()),
        ),

        // Bottom nav
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),
      ]),
    );
  }

  Widget _buildTopBar() {
    final user = ref.watch(authProvider).user;
    return ClipRect(child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 20, right: 20, bottom: 10),
        decoration: const BoxDecoration(
          color: Color(0x14FFFFFF),
          border: Border(bottom: BorderSide(color: Color(0x14FFFFFF), width: 0.5)),
        ),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), gradient: AppColors.emeraldGradient),
              child: const Center(child: Text('🌿', style: TextStyle(fontSize: 16)))),
          const SizedBox(width: 10),
          Text('MindfulMeals', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          const Spacer(),
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.white15)),
              child: Text('@${user.handle}', style: const TextStyle(color: AppColors.white50, fontSize: 11)),
            ),
          const SizedBox(width: 8),
          NeuButton(
            onTap: () {},
            borderRadius: 10, width: 34, height: 34, padding: EdgeInsets.zero,
            child: const Text('🔔', style: TextStyle(fontSize: 16)),
          ),
        ]),
      ),
    ));
  }

  Widget _buildBottomNav() {
    return ClipRect(child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
        decoration: const BoxDecoration(
          color: Color(0xEB080F18),
          border: Border(top: BorderSide(color: Color(0x14FFFFFF), width: 0.5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isActive = _currentIndex == i;
            return GestureDetector(
              onTap: () => _navigate(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(item.icon, style: TextStyle(fontSize: 20, color: isActive ? null : const Color(0x73FFFFFF))),
                  const SizedBox(height: 3),
                  Text(item.label, style: TextStyle(fontSize: 9,
                      color: isActive ? AppColors.accent : const Color(0x59FFFFFF),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: 0.3)),
                ]),
              ),
            );
          }),
        ),
      ),
    ));
  }
}
