import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/auth/signup_screen.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum AuthViewMode { welcome, signIn }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  AuthViewMode _viewMode = AuthViewMode.welcome;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _switchMode(AuthViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
    _animController.reset();
    _animController.forward();
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text,
      _passwordController.text,
    );
    if (!success && mounted) {
      _showErrorSnackBar(auth.error ?? 'Login failed');
    }
  }

  Future<void> _continueWithSocial(String providerName) async {
    final auth = context.read<AuthProvider>();
    // Fast guest sign-in for seamless experience & testing
    final success = await auth.signInAnonymously();
    if (!success && mounted) {
      _showErrorSnackBar(auth.error ?? 'Could not sign in with $providerName');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: AppTheme.expenseRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: _viewMode == AuthViewMode.welcome
              ? _buildWelcomeView(isDark)
              : _buildSignInView(isDark),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── WELCOME VIEW (Exact match to Finora Left Screen) ───────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWelcomeView(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),

          // ── Centered illustrated waving avatar ────────────────────────────
          const FinoraAvatar(
            size: 130,
            isWaving: true,
            showAddBadge: false,
          ),
          const SizedBox(height: 28),

          // ── Heading & Subtitle ────────────────────────────────────────────
          Text(
            'Welcome to Finora',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Explore a modern experience built for speed and simplicity.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // ── "Get Started" Pill Button (#1877F2) ─────────────────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── "── Or ──" Divider ─────────────────────────────────────────────
          _buildOrDivider(isDark),
          const SizedBox(height: 24),

          // ── Social Login Pill Buttons ──────────────────────────────────────
          _buildPillSocialButton(
            isDark: isDark,
            icon: const GoogleLogo(size: 20),
            label: 'Continue with Google',
            onTap: () => _continueWithSocial('Google'),
          ),
          const SizedBox(height: 14),

          _buildPillSocialButton(
            isDark: isDark,
            icon: AppleLogo(
              size: 22,
              color: isDark ? Colors.white : Colors.black,
            ),
            label: 'Continue with Apple',
            onTap: () => _continueWithSocial('Apple'),
          ),
          const SizedBox(height: 14),

          _buildPillSocialButton(
            isDark: isDark,
            icon: const FacebookLogo(size: 22),
            label: 'Continue with Facebook',
            onTap: () => _continueWithSocial('Facebook'),
          ),
          const SizedBox(height: 32),

          // ── Footer: Already have an account? Sign In ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
              GestureDetector(
                onTap: () => _switchMode(AuthViewMode.signIn),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── SIGN IN VIEW (Matching Finora aesthetic with email & password) ─────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSignInView(bool isDark) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Top back button row
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                onPressed: () => _switchMode(AuthViewMode.welcome),
              ),
            ),
            const SizedBox(height: 4),

            // ── Centered avatar ─────────────────────────────────────────────
            const FinoraAvatar(
              size: 96,
              isWaving: false,
              showAddBadge: false,
            ),
            const SizedBox(height: 20),

            // ── Heading & Subtitle ──────────────────────────────────────────
            Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to access your expenses and budget.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 26),

            // ── Email Input ─────────────────────────────────────────────────
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
              decoration: _inputDecoration(
                hint: 'Enter your email',
                isDark: isDark,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Password Input ──────────────────────────────────────────────
            Text(
              'Password',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
              decoration: _inputDecoration(
                hint: 'Enter your password',
                isDark: isDark,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF71717A)
                        : const Color(0xFF9CA3AF),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Sign In Button (#1877F2) ────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _loginWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 22),

            // ── "── Or ──" Divider ───────────────────────────────────────────
            _buildOrDivider(isDark),
            const SizedBox(height: 20),

            // ── 3 Circular Social Buttons ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularSocialButton(
                  isDark: isDark,
                  icon: const GoogleLogo(size: 20),
                  onTap: () => _continueWithSocial('Google'),
                ),
                const SizedBox(width: 18),
                _buildCircularSocialButton(
                  isDark: isDark,
                  icon: AppleLogo(
                    size: 22,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onTap: () => _continueWithSocial('Apple'),
                ),
                const SizedBox(width: 18),
                _buildCircularSocialButton(
                  isDark: isDark,
                  icon: const FacebookLogo(size: 22),
                  onTap: () => _continueWithSocial('Facebook'),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // ── Footer: Don't have an account? Sign Up ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildOrDivider(bool isDark) {
    final lineColor =
        isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Or',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF71717A) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, thickness: 1)),
      ],
    );
  }

  Widget _buildPillSocialButton({
    required bool isDark,
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final borderColor =
        isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final cardBg = isDark ? const Color(0xFF121212) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            icon,
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(width: 20), // keeps label centered
          ],
        ),
      ),
    );
  }

  Widget _buildCircularSocialButton({
    required bool isDark,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    final borderColor =
        isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final cardBg = isDark ? const Color(0xFF121212) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cardBg,
          border: Border.all(color: borderColor, width: 1.2),
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    final borderColor =
        isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF121212) : Colors.white;

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: isDark ? const Color(0xFF71717A) : const Color(0xFF9CA3AF),
      ),
      filled: true,
      fillColor: fillColor,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.expenseRed, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.expenseRed, width: 1.5),
      ),
    );
  }
}
