import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _handleCtrl   = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    _nameCtrl.dispose();  _handleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(authProvider.notifier);
    bool ok;
    if (_isLogin) {
      ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    } else {
      ok = await auth.register(_emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim(), _handleCtrl.text.trim().toLowerCase());
    }
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authProvider).error ?? 'Something went wrong'),
        backgroundColor: AppColors.coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
        const AmbientBlob(alignment: Alignment(-0.8, -0.6), color: AppColors.primary, size: 280),
        const AmbientBlob(alignment: Alignment(0.8, 0.8), color: AppColors.emerald, size: 200),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: AppColors.emeraldGradient,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24)]),
                child: const Center(child: Text('🌿', style: TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: 16),
              Text('MindfulMeals', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Mood · Food · Feeling Better', style: TextStyle(color: AppColors.white50, fontSize: 13)),
              const SizedBox(height: 40),
              // Form card
              GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_isLogin ? 'Welcome back' : 'Create account',
                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_isLogin ? 'Sign in to continue' : 'Start your mindful journey',
                      style: const TextStyle(color: AppColors.white50, fontSize: 13)),
                  const SizedBox(height: 24),
                  if (!_isLogin) ...[
                    _Field('Full Name', _nameCtrl, icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _Field('Handle (e.g. alex_mindful)', _handleCtrl, icon: Icons.alternate_email),
                    const SizedBox(height: 12),
                  ],
                  _Field('Email', _emailCtrl, icon: Icons.email_outlined, type: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _Field('Password', _passwordCtrl, icon: Icons.lock_outline, obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.white50, size: 18),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )),
                  const SizedBox(height: 24),
                  NeuButton(
                    active: true, onTap: authState.isLoading ? null : _submit,
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), borderRadius: 16,
                    child: authState.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isLogin ? 'Sign In' : 'Create Account',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 16),
                  Center(child: GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: RichText(text: TextSpan(
                      style: const TextStyle(color: AppColors.white50, fontSize: 13),
                      children: [
                        TextSpan(text: _isLogin ? "Don't have an account? " : 'Already have an account? '),
                        TextSpan(text: _isLogin ? 'Sign up' : 'Sign in',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    )),
                  )),
                ]),
              ),
              const SizedBox(height: 20),
              // Demo hint
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(children: const [
                  Text('Demo credentials', style: TextStyle(color: AppColors.white50, fontSize: 11)),
                  SizedBox(height: 4),
                  Text('alex@demo.com  ·  password123',
                      style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('(Works after running migrations/002_seed.sql)',
                      style: TextStyle(color: AppColors.white50, fontSize: 10)),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _Field(String label, TextEditingController ctrl, {IconData? icon, bool obscure = false, Widget? suffix, TextInputType? type}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(children: [
          if (icon != null) Icon(icon, color: AppColors.white50, size: 18),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: ctrl, obscureText: obscure, keyboardType: type,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(border: InputBorder.none, hintText: label,
                hintStyle: const TextStyle(color: AppColors.white50, fontSize: 13), suffixIcon: suffix),
          )),
        ]),
      ),
    ]);
  }
}
