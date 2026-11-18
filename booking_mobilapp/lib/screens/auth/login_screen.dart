import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/app_logo.dart';
import '../home/home_screen.dart';
import '../admin/super_admin_screen.dart';
import '../admin/sub_admin_screen.dart';
import '../admin/hotel_manager_screen.dart';
import '../admin/broker_screen.dart';
import 'register_screen.dart';
import 'otp_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  String? _errorMsg;

  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.94, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _routeByRole(String role) {
    Widget dest;
    switch (role) {
      case 'super_admin':   dest = const SuperAdminScreen();    break;
      case 'sub_admin':     dest = const SubAdminScreen();      break;
      case 'hotel_manager': dest = const HotelManagerScreen();  break;
      case 'broker':        dest = const BrokerScreen();        break;
      default:              dest = const HomeScreen();
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => dest), (_) => false);
  }

  Future<void> _submit() async {
    setState(() => _errorMsg = null);
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
        email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      _routeByRole(auth.user?.role ?? 'user');
    } else {
      setState(() => _errorMsg = auth.error ?? 'Invalid email or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang    = context.watch<LanguageProvider>();
    final loading = context.watch<AuthProvider>().loading;
    final size    = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF312E81)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // ── Top bar: back + lang ───────────────────────────────
                    Row(children: [
                      if (Navigator.canPop(context))
                        _BackBtn(onTap: () => Navigator.pop(context))
                      else
                        const SizedBox(width: 40),
                      const Spacer(),
                      _LangPill(lang: lang),
                    ]),
                    const SizedBox(height: 28),

                    // ── Brand mark ────────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Column(children: [
                          // EthioStay logo — replaces the 'D' badge
                          AppLogo(size: 88, showText: false),
                          const SizedBox(height: 14),
                          RichText(
                            text: const TextSpan(children: [
                              TextSpan(
                                text: 'Ethio',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w900,
                                    color: Colors.white, letterSpacing: 0.4),
                              ),
                              TextSpan(
                                text: 'Stay',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w900,
                                    color: Color(0xFFD4AF37), letterSpacing: 0.4),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18))),
                            child: Text(
                              lang.isAmharic
                                  ? 'የኢትዮጵያ ቀዳሚ የሆቴል ቦኪንግ ሲስተም'
                                  : "Ethiopia's Premier Hotel Booking",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Login card ────────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: _LoginCard(
                          formKey:   _formKey,
                          emailCtrl: _emailCtrl,
                          passCtrl:  _passCtrl,
                          obscure:   _obscure,
                          loading:   loading,
                          errorMsg:  _errorMsg,
                          lang:      lang,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                          onSubmit: _submit,
                          onForgot: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen())),
                          onRegister: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen())),
                          onOtp: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const OtpScreen())),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Trust badges ──────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: _TrustRow(lang: lang),
                    ),
                    const SizedBox(height: 24),

                    Text('© 2026 EthioStay',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.3))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN CARD — compact white card with all form elements
// ─────────────────────────────────────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading;
  final String? errorMsg;
  final LanguageProvider lang;
  final VoidCallback onToggleObscure, onSubmit, onForgot, onRegister, onOtp;

  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.errorMsg,
    required this.lang,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgot,
    required this.onRegister,
    required this.onOtp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 40,
              offset: const Offset(0, 12)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.login_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  lang.isAmharic ? 'እንኳን ደህና መጡ' : 'Welcome back',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                Text(
                  lang.isAmharic ? 'ወደ ሒሳብዎ ይግቡ' : 'Sign in to your account',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ]),
            ]),

            // Error banner
            if (errorMsg != null) ...[
              const SizedBox(height: 14),
              _ErrorBanner(message: errorMsg!),
            ],

            const SizedBox(height: 18),

            // Email
            _FieldLabel(
                lang.isAmharic ? 'ኢሜይል' : 'Email', required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller:   emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return lang.isAmharic ? 'ኢሜይል አስፈላጊ ነው' : 'Email is required';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(v.trim())) {
                  return lang.isAmharic ? 'ትክክለኛ ኢሜይል አስገቡ' : 'Enter a valid email';
                }
                return null;
              },
              decoration: _inputDeco(
                  lang.isAmharic ? 'you@example.com' : 'you@example.com',
                  Icons.mail_outline_rounded),
            ),
            const SizedBox(height: 14),

            // Password row with forgot link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _FieldLabel(
                    lang.isAmharic ? 'የይለፍ ቃል' : 'Password',
                    required: true),
                GestureDetector(
                  onTap: onForgot,
                  child: Text(
                    lang.isAmharic ? 'ረሱ?' : 'Forgot?',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller:  passCtrl,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              validator: (v) => (v == null || v.isEmpty)
                  ? (lang.isAmharic ? 'የይለፍ ቃል አስፈላጊ ነው' : 'Password is required')
                  : null,
              decoration: _inputDeco(
                      '••••••••', Icons.lock_outline_rounded)
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textHint),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign In button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(
                        lang.isAmharic ? 'ግባ' : 'Sign In',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  lang.isAmharic ? 'ወይም' : 'or',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textHint),
                ),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 14),

            // Register + OTP row
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRegister,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(
                    lang.isAmharic ? 'ምዝገባ' : 'Register',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onOtp,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(
                    lang.isAmharic ? 'OTP ግባ' : 'OTP Login',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText:        hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled:          true,
        fillColor:       AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.8)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.8)),
        errorStyle:
            const TextStyle(fontSize: 11, color: AppColors.error),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3))),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRUST ROW
// ─────────────────────────────────────────────────────────────────────────────
class _TrustRow extends StatelessWidget {
  final LanguageProvider lang;
  const _TrustRow({required this.lang});

  @override
  Widget build(BuildContext context) {
    final items = lang.isAmharic
        ? ['🔒 ደህንነቱ ተጠብቋል', '🏨 የተረጋገጡ ሆቴሎች', '📱 ቀላል ቦኪንግ']
        : ['🔒 Secure Login', '🏨 Verified Hotels', '📱 Easy Booking'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18))),
          child: Text(item,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ),
      )).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE BITS
// ─────────────────────────────────────────────────────────────────────────────
class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 15),
        ),
      );
}

class _LangPill extends StatelessWidget {
  final LanguageProvider lang;
  const _LangPill({required this.lang});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: lang.toggle,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(lang.isAmharic ? '🇬🇧' : '🇪🇹',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(lang.isAmharic ? 'EN' : 'አማ',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          children: required
              ? const [
                  TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error))
                ]
              : [],
        ),
      );
}
