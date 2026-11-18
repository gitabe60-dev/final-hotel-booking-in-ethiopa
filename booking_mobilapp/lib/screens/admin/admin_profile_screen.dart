import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/admin_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/snack_helper.dart';
import '../auth/login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});
  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _curPwCtrl   = TextEditingController();
  final _newPwCtrl   = TextEditingController();
  final _confPwCtrl  = TextEditingController();

  bool _saving   = false;
  bool _changePw = false;
  bool _showNew  = false;
  bool _showCur  = false;

  // Profile data loaded from /api/admin/profile
  Map<String, dynamic> _profile = {};
  bool _loading = true;
  int  _unread  = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _curPwCtrl.dispose(); _newPwCtrl.dispose(); _confPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      // GET /api/admin/profile
      final res = await ApiService.instance.adminGet(AdminEndpoints.profile);
      final d   = res['data'] as Map<String, dynamic>? ?? {};
      setState(() {
        _profile  = d;
        _unread   = d['unread_messages'] as int? ?? 0;
        _nameCtrl.text  = d['full_name']?.toString() ?? '';
        _phoneCtrl.text = d['phone']?.toString() ?? '';
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      showError(context, 'Full name is required'); return;
    }
    setState(() => _saving = true);
    try {
      // PUT /api/admin/profile  { full_name, phone? }
      await ApiService.instance.adminPut(
        AdminEndpoints.updateProfile,
        data: {
          'full_name': _nameCtrl.text.trim(),
          if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        },
      );
      showSuccess(context, 'Profile updated!');
    } on ApiException catch (e) {
      showError(context, e.message);
    }
    setState(() => _saving = false);
  }

  Future<void> _changePassword() async {
    if (_curPwCtrl.text.isEmpty) { showError(context, 'Enter current password'); return; }
    if (_newPwCtrl.text.length < 6) { showError(context, 'Min 6 characters'); return; }
    if (_newPwCtrl.text != _confPwCtrl.text) { showError(context, 'Passwords do not match'); return; }

    setState(() => _changePw = true);
    try {
      // POST /api/admin/change-password  { current_password, new_password }
      await ApiService.instance.adminPost(
        AdminEndpoints.changePassword,
        data: {
          'current_password': _curPwCtrl.text,
          'new_password':     _newPwCtrl.text,
        },
      );
      showSuccess(context, 'Password changed!');
      _curPwCtrl.clear(); _newPwCtrl.clear(); _confPwCtrl.clear();
    } on ApiException catch (e) {
      showError(context, e.message);
    }
    setState(() => _changePw = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final role  = _profile['role']?.toString() ?? auth.user?.role ?? '';

    const roleMeta = <String, Map<String, dynamic>>{
      'super_admin':   {'label': 'Super Admin',   'color': Color(0xFF7C3AED)},
      'sub_admin':     {'label': 'Sub Admin',     'color': Color(0xFF2563EB)},
      'hotel_manager': {'label': 'Hotel Manager', 'color': Color(0xFF059669)},
      'broker':        {'label': 'Broker',        'color': Color(0xFFD97706)},
    };
    final meta  = roleMeta[role] ?? {'label': role, 'color': AppColors.primary};
    final color = meta['color'] as Color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(title: 'My Profile', dark: true, backgroundColor: color),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Avatar + role ───────────────────────────────────────────
                Center(child: Column(children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [color, Color.lerp(color, Colors.black, 0.2)!]),
                      shape:     BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 34, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_nameCtrl.text,
                      style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(_profile['email']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.3))),
                    child: Text(meta['label'] as String,
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w700, color: color)),
                  ),
                  if (_unread > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('$_unread unread message${_unread > 1 ? "s" : ""}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ])),
                const SizedBox(height: 24),

                // ── Edit profile ────────────────────────────────────────────
                _card(
                  icon: Icons.person_outline_rounded,
                  iconBg: color.withOpacity(0.1),
                  iconColor: color,
                  title: 'Profile Information',
                  subtitle: 'Update your name and phone number',
                  child: Column(children: [
                    _lf('Full Name *', _nameCtrl, 'Your full name'),
                    const SizedBox(height: 14),
                    _lf('Phone', _phoneCtrl, '+251911000000',
                        type: TextInputType.phone),
                    const SizedBox(height: 14),
                    // Read-only email
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceGray,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        const Icon(Icons.mail_outline_rounded,
                            size: 16, color: AppColors.textHint),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('Email',
                              style: TextStyle(fontSize: 10,
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w600)),
                          Text(_profile['email']?.toString() ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                        ])),
                        const Text('Read-only',
                            style: TextStyle(
                                fontSize: 9, color: AppColors.textHint)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_outlined, size: 18),
                        label: Text(_saving ? 'Saving…' : 'Save Profile',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Change password ─────────────────────────────────────────
                _card(
                  icon: Icons.lock_outline_rounded,
                  iconBg: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFD97706),
                  title: 'Change Password',
                  subtitle: 'Keep your admin account secure',
                  child: Column(children: [
                    _pw('Current Password', _curPwCtrl, _showCur,
                        () => setState(() => _showCur = !_showCur)),
                    const SizedBox(height: 14),
                    _pw('New Password', _newPwCtrl, _showNew,
                        () => setState(() => _showNew = !_showNew)),
                    const SizedBox(height: 14),
                    _pw('Confirm New Password', _confPwCtrl, true, null,
                        readonly: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _changePw ? null : _changePassword,
                        icon: _changePw
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.lock_reset_rounded, size: 18),
                        label: Text(_changePw ? 'Changing…' : 'Change Password',
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
                const SizedBox(height: 16),

                // ── Logout ──────────────────────────────────────────────────
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
                    label: const Text('Sign Out',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
    );
  }

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
              Text(title, style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(
                  fontSize: 11, color: AppColors.textHint)),
            ]),
          ]),
          const SizedBox(height: 16),
          child,
        ]),
      );

  Widget _lf(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl, keyboardType: type,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ]);

  Widget _pw(String label, TextEditingController ctrl, bool show,
      VoidCallback? onToggle, {bool readonly = false}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: !show,
          onChanged: readonly ? null : (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: label,
            suffixIcon: onToggle != null
                ? IconButton(
                    icon: Icon(show
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                        size: 18, color: AppColors.textHint),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ]);
}
