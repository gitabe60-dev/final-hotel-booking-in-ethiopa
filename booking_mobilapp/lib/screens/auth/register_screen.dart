import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/snack_helper.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _natCtrl   = TextEditingController();

  bool _obscure       = true;
  bool _uploadingFront = false;
  bool _uploadingBack  = false;

  // National ID photos as base64 (same as web — sent with register request)
  String? _idFrontB64;
  String? _idBackB64;

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose(); _natCtrl.dispose();
    super.dispose();
  }

  // ── password strength ──────────────────────────────────────────────────────
  int _strength(String v) {
    if (v.isEmpty) return 0;
    int s = 0;
    if (v.length >= 6)  s++;
    if (v.length >= 10) s++;
    if (RegExp(r'[A-Z]').hasMatch(v))          s++;
    if (RegExp(r'[0-9]').hasMatch(v))          s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) s++;
    return s;
  }

  Color _strengthColor(int s) => const [
    AppColors.border,
    AppColors.error,
    Colors.orange,
    Colors.amber,
    AppColors.success,
    Color(0xFF047857),
  ][s.clamp(0, 5)];

  String _strengthLabel(int s) =>
      ['', 'Weak', 'Fair', 'Good', 'Strong', 'Very Strong'][s.clamp(0, 5)];

  // ── image pick → base64 ───────────────────────────────────────────────────
  Future<String?> _pickImage() async {
    final f = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 1200);
    if (f == null) return null;
    final bytes = await File(f.path).readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  Future<void> _pickFront() async {
    setState(() => _uploadingFront = true);
    _idFrontB64 = await _pickImage();
    setState(() => _uploadingFront = false);
  }

  Future<void> _pickBack() async {
    setState(() => _uploadingBack = true);
    _idBackB64 = await _pickImage();
    setState(() => _uploadingBack = false);
  }

  // ── submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_emailCtrl.text.trim().isEmpty && _phoneCtrl.text.trim().isEmpty) {
      showError(context, 'Please provide email or phone number.'); return;
    }
    // ID photos are optional at registration (same as web)
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      firstName:   _firstCtrl.text.trim(),
      lastName:    _lastCtrl.text.trim(),
      email:       _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone:       _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      password:    _passCtrl.text,
      nationality: _natCtrl.text.trim().isEmpty  ? null : _natCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      showSuccess(context, 'Account created! Welcome to EthioStay 🎉');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } else {
      showError(context, auth.error ?? 'Registration failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading  = context.watch<AuthProvider>().loading;
    final strength = _strength(_passCtrl.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Create Account',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(children: [

            // ── Logo + intro ───────────────────────────────────────────────
            Center(
              child: Column(children: [
                AppLogo(size: 80, showText: false),
                const SizedBox(height: 14),
                RichText(
                  text: const TextSpan(children: [
                    TextSpan(text: 'Join ',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary)),
                    TextSpan(text: 'Ethio',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                            color: AppColors.primary)),
                    TextSpan(text: 'Stay',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                            color: Color(0xFFD4AF37))),
                  ]),
                ),
                const SizedBox(height: 4),
                const Text("Ethiopia's Premier Hotel Booking",
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Card 1: Personal information ───────────────────────────────
            _Card(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              child: Column(children: [
                Row(children: [
                  Expanded(child: _field(
                    label: 'First Name', ctrl: _firstCtrl,
                    hint: 'Abebe', required: true,
                    validator: V.name,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _field(
                    label: 'Last Name', ctrl: _lastCtrl,
                    hint: 'Kebede', required: true,
                    validator: V.name,
                  )),
                ]),
                const SizedBox(height: 14),
                _field(
                  label: 'Email Address', ctrl: _emailCtrl,
                  hint: 'you@example.com',
                  type: TextInputType.emailAddress,
                  icon: Icons.mail_outline_rounded,
                  helper: 'Required if no phone',
                  validator: (v) => V.email(v, required: false),
                ),
                const SizedBox(height: 14),
                _field(
                  label: 'Phone Number', ctrl: _phoneCtrl,
                  hint: '0912345678',
                  type: TextInputType.phone,
                  icon: Icons.phone_outlined,
                  helper: 'Ethiopian number, required if no email',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: V.phoneOptional,
                ),
                const SizedBox(height: 14),
                _field(
                  label: 'Nationality', ctrl: _natCtrl,
                  hint: 'Ethiopian (optional)',
                  icon: Icons.public_outlined,
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // ── Card 2: Password ───────────────────────────────────────────
            _Card(
              icon: Icons.lock_outline_rounded,
              title: 'Password',
              child: Column(children: [
                _fieldLabel('Password', true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  onChanged: (_) => setState(() {}),
                  validator: V.password,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.lock_outline_rounded,
                            size: 18, color: AppColors.textHint)),
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
                ),
                if (_passCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Strength bar
                  Row(children: List.generate(5, (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < strength
                            ? _strengthColor(strength)
                            : AppColors.surfaceGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ))),
                  const SizedBox(height: 5),
                  Row(children: [
                    Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: _strengthColor(strength),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(_strengthLabel(strength),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _strengthColor(strength))),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 14),

            // ── Card 3: National ID / Passport ─────────────────────────────
            _Card(
              icon: Icons.badge_outlined,
              title: 'National ID / Passport',
              subtitle: 'Upload for identity verification (optional at signup, required at check-in)',
              child: Column(children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Upload both sides of your National ID or passport. '
                          'This is used by the hotel to verify your identity at check-in.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Upload boxes
                Row(children: [
                  Expanded(child: _IdUpload(
                    label: 'Front Side',
                    subtitle: 'Photo of ID front',
                    b64: _idFrontB64,
                    uploading: _uploadingFront,
                    onTap: _pickFront,
                    onRemove: _idFrontB64 != null
                        ? () => setState(() => _idFrontB64 = null)
                        : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _IdUpload(
                    label: 'Back Side',
                    subtitle: 'Photo of ID back',
                    b64: _idBackB64,
                    uploading: _uploadingBack,
                    onTap: _pickBack,
                    onRemove: _idBackB64 != null
                        ? () => setState(() => _idBackB64 = null)
                        : null,
                  )),
                ]),
                if (_idFrontB64 != null && _idBackB64 != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            color: AppColors.success, size: 16),
                        SizedBox(width: 8),
                        Text('Both ID photos attached ✓',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 14),

            // ── Terms note ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'By creating an account you agree to DallolBook\'s terms '
                      'of service and privacy policy.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF92400E), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Create Account',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Sign-in link ───────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Sign In',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Field helpers ─────────────────────────────────────────────────────────
  Widget _fieldLabel(String text, bool req) => RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          children: req
              ? const [
                  TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error))
                ]
              : [],
        ),
      );

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    TextInputType type = TextInputType.text,
    IconData? icon,
    String? helper,
    bool required = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _fieldLabel(label, required),
      const SizedBox(height: 6),
      TextFormField(
        controller:      ctrl,
        keyboardType:    type,
        validator:       validator,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText:   hint,
          helperText: helper,
          helperStyle: const TextStyle(fontSize: 11),
          prefixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(icon, size: 18, color: AppColors.textHint))
              : null,
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  subtitle;
  final Widget   child;

  const _Card({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color:  Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// National ID upload box
// ─────────────────────────────────────────────────────────────────────────────
class _IdUpload extends StatelessWidget {
  final String     label;
  final String     subtitle;
  final String?    b64;
  final bool       uploading;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _IdUpload({
    required this.label,
    required this.subtitle,
    this.b64,
    required this.uploading,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImg = b64 != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 2),
      Text(subtitle,
          style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: uploading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 120,
          decoration: BoxDecoration(
            color: hasImg
                ? AppColors.successLight
                : AppColors.surfaceGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImg ? AppColors.success : AppColors.border,
              width: hasImg ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: uploading
              ? const Center(
                  child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.primary)))
              : hasImg
                  ? Stack(fit: StackFit.expand, children: [
                      Image.memory(
                        base64Decode(b64!.contains(',')
                            ? b64!.split(',').last
                            : b64!),
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.15)),
                      ),
                      Positioned(bottom: 0, left: 0, right: 0,
                        child: Container(
                          color: AppColors.success.withOpacity(0.88),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white, size: 13),
                              SizedBox(width: 5),
                              Text('Attached',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      if (onRemove != null)
                        Positioned(top: 6, right: 6,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                    ])
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo_rounded,
                              size: 22, color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        const Text('Tap to upload',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        const Text('JPG or PNG',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textHint)),
                      ],
                    ),
        ),
      ),
    ]);
  }
}
