import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/snack_helper.dart';
import '../home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  bool  _sent      = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      showError(context, 'Enter phone number'); return;
    }
    final auth = context.read<AuthProvider>();
    final ok   = await auth.sendOtp(_phoneCtrl.text.trim(), purpose: 'login');
    if (!mounted) return;
    if (ok) { setState(() => _sent = true); showSuccess(context, 'OTP sent!'); }
    else      showError(context, auth.error ?? 'Failed to send OTP');
  }

  Future<void> _verify() async {
    if (_otpCtrl.text.trim().isEmpty) {
      showError(context, 'Enter OTP code'); return;
    }
    final auth = context.read<AuthProvider>();
    final ok   = await auth.verifyOtp(
        _phoneCtrl.text.trim(), _otpCtrl.text.trim(), purpose: 'login');
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false);
    } else {
      showError(context, auth.error ?? 'Invalid OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context);
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(title: l10n.t('otp_login')),
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
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.phone_android_rounded,
                      color: AppColors.primary, size: 30)),
                const SizedBox(height: 16),
                const Text('Phone Verification',
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Enter your phone to receive a one-time password',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
              ])),
              const SizedBox(height: 24),

              const Text('Phone Number',
                  style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller:      _phoneCtrl,
                enabled:         !_sent,
                keyboardType:    TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: '+251911000000',
                  prefixIcon: Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.phone_outlined, size: 18,
                          color: AppColors.textHint)),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),

              if (_sent) ...[
                const SizedBox(height: 20),
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
                  textAlign:  TextAlign.center,
                  style: const TextStyle(fontSize: 28,
                      fontWeight: FontWeight.w800, letterSpacing: 12),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(letterSpacing: 12)),
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : (_sent ? _verify : _sendOtp),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5,
                              color: Colors.white))
                      : Text(_sent ? 'Verify & Login' : 'Send OTP',
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),

              if (_sent) ...[
                const SizedBox(height: 12),
                Center(child: TextButton(
                  onPressed: () => setState(() {
                    _sent = false;
                    _otpCtrl.clear();
                  }),
                  child: const Text('Change phone number',
                      style: TextStyle(color: AppColors.primary)),
                )),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
