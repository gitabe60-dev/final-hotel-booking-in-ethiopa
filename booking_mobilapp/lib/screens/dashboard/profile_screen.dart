import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/snack_helper.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstCtrl    = TextEditingController();
  final _lastCtrl     = TextEditingController();
  final _natCtrl      = TextEditingController();
  final _curPassCtrl  = TextEditingController();
  final _newPassCtrl  = TextEditingController();
  final _confPassCtrl = TextEditingController();
  bool _showCurPass  = false;
  bool _showNewPass  = false;
  bool _changingPw   = false;
  final _profileKey  = GlobalKey<FormState>();
  final _passKey     = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstCtrl.text = user.firstName;
      _lastCtrl.text  = user.lastName;
      _natCtrl.text   = user.nationality ?? '';
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose(); _natCtrl.dispose();
    _curPassCtrl.dispose(); _newPassCtrl.dispose(); _confPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      firstName:   _firstCtrl.text.trim(),
      lastName:    _lastCtrl.text.trim(),
      nationality: _natCtrl.text.trim().isEmpty ? null : _natCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) showSuccess(context, 'Profile updated!');
    else    showError(context, auth.error ?? 'Failed to update profile');
  }

  Future<void> _changePassword() async {
    if (!_passKey.currentState!.validate()) return;
    setState(() => _changingPw = true);
    try {
      await ApiService.instance.post(
        ApiEndpoints.guestChangePassword,
        data: {
          'current_password': _curPassCtrl.text,
          'new_password':     _newPassCtrl.text,
        },
      );
      if (mounted) {
        showSuccess(context, 'Password changed successfully!');
        _curPassCtrl.clear();
        _newPassCtrl.clear();
        _confPassCtrl.clear();
      }
    } on ApiException catch (e) {
      if (mounted) showError(context, e.message);
    }
    setState(() => _changingPw = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: DallolAppBar(title: l10n.t('my_profile')),
        body: Center(child: ElevatedButton(
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: Text(l10n.t('sign_in')),
        )),
      );
    }

    final user = auth.user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(
        title:    l10n.t('my_profile'),
        showBack: Navigator.canPop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Avatar ────────────────────────────────────────────────────
          Center(child: Column(children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight),
                shape:     BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Center(child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : 'G',
                style: const TextStyle(color: Colors.white,
                    fontSize: 34, fontWeight: FontWeight.w900),
              )),
            ),
            const SizedBox(height: 14),
            Text(user.fullName,
                style: const TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            if (user.email != null)
              Text(user.email!,
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
            if (user.phone != null)
              Text(user.phone!,
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                user.role[0].toUpperCase() + user.role.substring(1),
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
          ])),
          const SizedBox(height: 24),

          // ── Personal Info ─────────────────────────────────────────────
          _card(
            icon:      Icons.person_outline_rounded,
            iconBg:    AppColors.primaryLight,
            iconColor: AppColors.primary,
            title:     l10n.t('personal_info_tab'),
            subtitle:  'Update your name and nationality',
            child: Form(
              key: _profileKey,
              child: Column(children: [
                Row(children: [
                  Expanded(child: _field('First Name *', _firstCtrl, 'Abebe',
                      validator: V.name)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Last Name *', _lastCtrl, 'Kebede',
                      validator: V.name)),
                ]),
                const SizedBox(height: 14),
                _field(l10n.t('nationality'), _natCtrl,
                    'Ethiopian (optional)',
                    icon: Icons.public_outlined),
                const SizedBox(height: 14),
                if (user.email != null)
                  _readOnly(l10n.t('email'), user.email!,
                      Icons.mail_outline_rounded, l10n),
                if (user.phone != null) ...[
                  const SizedBox(height: 10),
                  _readOnly(l10n.t('phone'), user.phone!,
                      Icons.phone_outlined, l10n),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: auth.loading ? null : _saveProfile,
                    icon: auth.loading
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(auth.loading
                        ? l10n.t('saving')
                        : l10n.t('save_profile'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ── Change Password ────────────────────────────────────────────
          _card(
            icon:      Icons.lock_outline_rounded,
            iconBg:    const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFD97706),
            title:     l10n.t('change_password'),
            subtitle:  'Keep your account secure',
            child: Form(
              key: _passKey,
              child: Column(children: [
                _pwField(l10n.t('current_password'),
                    _curPassCtrl, _showCurPass,
                    () => setState(() => _showCurPass = !_showCurPass),
                    validator: (v) => V.required(v, label: 'Current password')),
                const SizedBox(height: 14),
                _pwField(l10n.t('new_password'),
                    _newPassCtrl, _showNewPass,
                    () => setState(() => _showNewPass = !_showNewPass),
                    validator: V.password),
                const SizedBox(height: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.t('confirm_password'),
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller:  _confPassCtrl,
                    obscureText: true,
                    validator:   (v) => V.confirmPassword(v, _newPassCtrl.text),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged:   (_) => setState(() {}),
                    decoration: const InputDecoration(
                        hintText:   'Re-enter new password',
                        errorStyle: TextStyle(
                            fontSize: 11, color: AppColors.error)),
                  ),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _changingPw ? null : _changePassword,
                    icon: _changingPw
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.lock_reset_rounded, size: 18),
                    label: Text(_changingPw
                        ? 'Changing…'
                        : l10n.t('change_password'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ── Sign Out ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (_) => false);
                }
              },
              icon:  const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(l10n.t('sign_out'),
                  style: const TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _card({required IconData icon, required Color iconBg,
    required Color iconColor, required String title,
    required String subtitle, required Widget child}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(
                  fontSize: 11, color: AppColors.textHint)),
            ]),
          ]),
          const SizedBox(height: 16),
          child,
        ]),
      );

  Widget _field(String label, TextEditingController ctrl, String hint,
      {IconData? icon, String? Function(String?)? validator}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          validator: validator,
          autovalidateMode: validator != null
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(icon, size: 16, color: AppColors.textHint))
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ]);

  Widget _pwField(String label, TextEditingController ctrl,
      bool show, VoidCallback onToggle, {String? Function(String?)? validator}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: !show,
          validator: validator,
          autovalidateMode: validator != null
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: label,
            errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
            suffixIcon: IconButton(
              icon: Icon(
                  show ? Icons.visibility_off_outlined
                       : Icons.visibility_outlined,
                  size: 18, color: AppColors.textHint),
              onPressed: onToggle,
            ),
          ),
        ),
      ]);

  Widget _readOnly(String label, String value, IconData icon,
      AppLocalizations l10n) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(
                fontSize: 10, color: AppColors.textHint,
                fontWeight: FontWeight.w600)),
            Text(value, style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.surfaceGray,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border)),
            child: Text(l10n.t('read_only'),
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textHint)),
          ),
        ]),
      );
}
