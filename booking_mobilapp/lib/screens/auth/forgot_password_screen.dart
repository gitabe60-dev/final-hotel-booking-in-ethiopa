import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/snack_helper.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl   = TextEditingController();
  final _otpCtrl     = TextEditingController();
  final _newPassCtrl = TextEditingController();
  int  _step         = 1;
  bool _obscure      = true;
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_step1Key.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.sendOtp(_phoneCtrl.text.trim(), purpose: 'reset');
    if (!mounted) return;
    if (ok) {
      setState(() => _step = 2);
      showSuccess(context, 'Reset code sent!');
    } else {
      showError(context, auth.error ?? 'Failed to send code');
    }
  }

  Future<void> _reset() async {
    if (!_step2Key.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.resetPassword(
        _phoneCtrl.text.trim(), _otpCtrl.text.trim(), _newPassCtrl.text);
    if (!mounted) return;
    if (ok) {
      showSuccess(context, 'Password reset! Please login.');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false);
    } else {
      showError(context, auth.error ?? 'Reset failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context);
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(title: l10n.t('forgot_password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20, offset: const Offset(0, 6))]),
            padding: const EdgeInsets.all(28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_reset_rounded,
                      color: Color(0xFFD97706), size: 30)),
                const SizedBox(height: 16),
                const Text('Reset Password',
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text("We'll send a code to your phone",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
              ])),
              const SizedBox(height: 24),

              // Step indicator
              Row(children: [
                _stepDot(1, 'Send Code'),
                Expanded(child: Container(height: 2,
                    color: _step > 1 ? AppColors.primary : AppColors.border)),
                _stepDot(2, 'Reset'),
              ]),
              const SizedBox(height: 24),

              Form(
                key: _step1Key,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Phone Number',
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller:      _phoneCtrl,
                    enabled:         _step == 1,
                    keyboardType:    TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator:       V.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      hintText: '0912345678',
                      errorStyle: TextStyle(fontSize: 11, color: AppColors.error),
                      prefixIcon: Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.phone_outlined, size: 18,
                              color: AppColors.textHint)),
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                  ),
                ]),
              ),

              if (_step == 2) ...[
                Form(key: _step2Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 16),
                const Text('OTP Code',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller:      _otpCtrl,
                  keyboardType:    TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: V.otp,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textAlign:  TextAlign.center,
                  style: const TextStyle(fontSize: 24,
                      fontWeight: FontWeight.w800, letterSpacing: 10),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    errorStyle: TextStyle(fontSize: 11, color: AppColors.error),
                    hintStyle: TextStyle(letterSpacing: 10)),
                ),
                const SizedBox(height: 16),
                const Text('New Password',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller:  _newPassCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Min 6 characters',
                    prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.lock_outline_rounded, size: 18,
                            color: AppColors.textHint)),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_outlined
                                   : Icons.visibility_off_outlined,
                          size: 20, color: AppColors.textHint),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: V.password,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                ])),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : (_step == 1 ? _sendOtp : _reset),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _step == 1
                          ? AppColors.primary
                          : AppColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5,
                              color: Colors.white))
                      : Text(_step == 1 ? 'Send Reset Code' : 'Reset Password',
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _stepDot(int num, String label) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: _step >= num ? AppColors.primary : AppColors.surfaceGray,
                shape: BoxShape.circle),
            child: Center(child: _step > num
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('$num',
                    style: TextStyle(
                        color: _step >= num ? Colors.white : AppColors.textHint,
                        fontWeight: FontWeight.w700, fontSize: 13))),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: _step >= num ? AppColors.primary : AppColors.textHint,
                  fontWeight: FontWeight.w600)),
        ],
      );
}
