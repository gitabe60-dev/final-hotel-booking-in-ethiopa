import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/validators.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/hotel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/snack_helper.dart';
import '../payment/payment_success_screen.dart';

// ── Ethiopian payment method metadata ─────────────────────────────────────────
const _pmMeta = <String, Map<String, dynamic>>{
  'telebirr':    {'label': 'Telebirr',           'emoji': '📱', 'color': Color(0xFF059669)},
  'cbe_birr':    {'label': 'CBE Birr',           'emoji': '🏦', 'color': Color(0xFFD97706)},
  'chapa':       {'label': 'Chapa',              'emoji': '🔵', 'color': Color(0xFF2563EB)},
  'awash_bank':  {'label': 'Awash Bank',         'emoji': '🏦', 'color': Color(0xFF7C3AED)},
  'abyssinia':   {'label': 'Bank of Abyssinia',  'emoji': '🏦', 'color': Color(0xFFDB2777)},
  'dashen':      {'label': 'Dashen Bank',        'emoji': '🏦', 'color': Color(0xFF0D9488)},
  'oromia_coop': {'label': 'Oromia Bank',        'emoji': '🏦', 'color': Color(0xFFEA580C)},
  'united':      {'label': 'United Bank',        'emoji': '🏦', 'color': Color(0xFF4F46E5)},
  'nib':         {'label': 'NIB International',  'emoji': '🏦', 'color': Color(0xFF65A30D)},
  'wegagen':     {'label': 'Wegagen Bank',       'emoji': '🏦', 'color': Color(0xFF0891B2)},
  'bunna':       {'label': 'Bunna Bank',         'emoji': '🏦', 'color': Color(0xFFA21CAF)},
  'cooperative': {'label': 'Cooperative Bank',   'emoji': '🏦', 'color': Color(0xFF047857)},
  'bank_transfer':{'label': 'Bank Transfer',     'emoji': '🏦', 'color': Color(0xFF374151)},
  'card':        {'label': 'Card Payment',       'emoji': '💳', 'color': Color(0xFF1D4ED8)},
  'mobile_money':{'label': 'Mobile Money',       'emoji': '📲', 'color': Color(0xFF059669)},
};

String _fmt(double v) => v.toStringAsFixed(0)
    .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

class BookingConfirmScreen extends StatefulWidget {
  final int hotelId;
  final String checkIn, checkOut;
  final int nights, roomId, rooms, maxGuests;
  final String roomName;
  final double roomPrice;

  const BookingConfirmScreen({
    super.key,
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.roomId,
    required this.roomName,
    required this.roomPrice,
    required this.rooms,
    required this.maxGuests,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  int _step = 1;
  final _formKey1 = GlobalKey<FormState>();

  // Step 1
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _natCtrl;
  late final TextEditingController _specialCtrl;
  int _adults = 1, _children = 0;
  String? _idFrontB64, _idBackB64;
  bool _uploadingFront = false, _uploadingBack = false;

  // Step 2
  String _payMethod = '';
  final _txnCtrl = TextEditingController();
  String? _screenshotB64;
  bool _uploadingShot = false;
  bool _submitting = false;
  bool _loadingPayMethods = false;
  List<PaymentMethod> _payMethods = [];
  // Manager contact loaded with payment methods
  String? _managerPhone;
  String? _managerName;
  String? _managerEmail;

  double get _total => widget.roomPrice * widget.nights * widget.rooms;
  int get _capacity => widget.maxGuests > 0 ? widget.maxGuests : widget.rooms * 2;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstCtrl   = TextEditingController(text: user?.firstName ?? '');
    _lastCtrl    = TextEditingController(text: user?.lastName  ?? '');
    _emailCtrl   = TextEditingController(text: user?.email     ?? '');
    _phoneCtrl   = TextEditingController(text: user?.phone     ?? '');
    _natCtrl     = TextEditingController(text: user?.nationality ?? '');
    _specialCtrl = TextEditingController();
    _adults      = _capacity.clamp(1, 99);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hp = context.read<HotelProvider>();
      if (hp.hotel?.id != widget.hotelId) hp.loadHotel(widget.hotelId);
      // Load payment methods directly — don't rely on provider's unawaited call
      _fetchPayMethods();
    });
  }

  // ── Load payment methods + manager contact directly from API ─────────────
  Future<void> _fetchPayMethods() async {
    setState(() => _loadingPayMethods = true);
    try {
      final res  = await ApiService.instance.get(
          ApiEndpoints.hotelPaymentMethods(widget.hotelId));
      final data = res['data'];
      List<dynamic> list = [];
      if (data is Map) {
        list             = data['methods'] as List<dynamic>? ?? [];
        _managerPhone    = data['manager_phone'] as String?;
        _managerName     = data['manager_name']  as String?;
        _managerEmail    = data['manager_email'] as String?;
      } else if (data is List) {
        list = data;
      }
      final methods = list
          .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _payMethods = methods;
          if (methods.isNotEmpty && _payMethod.isEmpty) {
            _payMethod = methods.first.method;
          }
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingPayMethods = false);
  }

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _natCtrl.dispose(); _specialCtrl.dispose();
    _txnCtrl.dispose();
    super.dispose();
  }

  // ── Image picker → base64 ─────────────────────────────────────────────────
  // Uses XFile.readAsBytes() which works on ALL platforms (web, desktop, mobile)
  // Does NOT use File() which breaks on web/Linux sometimes
  Future<String?> _pick() async {
    try {
      final picker = ImagePicker();
      final XFile? f = await picker.pickImage(
        source:       ImageSource.gallery,
        imageQuality: 80,
        maxWidth:     1200,
        maxHeight:    1200,
      );
      if (f == null) return null;
      // Use XFile.readAsBytes() — works on web, desktop, and mobile
      final bytes = await f.readAsBytes();
      if (bytes.isEmpty) return null;
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
      if (mounted) showError(context, 'Failed to pick image: $e');
      return null;
    }
  }

  Future<void> _pickFront() async {
    setState(() => _uploadingFront = true);
    final result = await _pick();
    if (mounted) setState(() {
      if (result != null) _idFrontB64 = result;
      _uploadingFront = false;
    });
  }

  Future<void> _pickBack() async {
    setState(() => _uploadingBack = true);
    final result = await _pick();
    if (mounted) setState(() {
      if (result != null) _idBackB64 = result;
      _uploadingBack = false;
    });
  }

  Future<void> _pickShot() async {
    setState(() => _uploadingShot = true);
    final result = await _pick();
    if (mounted) setState(() {
      if (result != null) _screenshotB64 = result;
      _uploadingShot = false;
    });
  }

  // ── Step 1 → 2 ────────────────────────────────────────────────────────────
  void _goStep2() {
    if (!_formKey1.currentState!.validate()) return;
    if (_emailCtrl.text.trim().isEmpty && _phoneCtrl.text.trim().isEmpty) {
      showError(context, 'Provide email or phone number'); return;
    }
    if ((_adults + _children) > _capacity) {
      showError(context, 'Total guests exceed room capacity ($_capacity)'); return;
    }
    // ID upload is OPTIONAL (same as web) — user can upload at check-in
    // No block here — just navigate to payment step
    setState(() => _step = 2);
  }

  // ── Final submit ───────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_payMethod.isEmpty)               { showError(context, 'Select a payment method'); return; }
    if (V.transactionId(_txnCtrl.text) != null) {
      showError(context, V.transactionId(_txnCtrl.text)!); return;
    }
    if (_screenshotB64 == null)           { showError(context, 'Payment screenshot is required'); return; }

    setState(() => _submitting = true);
    final bp = context.read<BookingProvider>();

    // Step 1: POST /bookings
    final ok1 = await bp.createBooking(
      hotelId:        widget.hotelId,
      roomTypeId:     widget.roomId,
      checkIn:        widget.checkIn,
      checkOut:       widget.checkOut,
      adults:         _adults,
      children:       _children,
      rooms:          widget.rooms,
      paymentMethod:  _payMethod,
      specialRequests: _specialCtrl.text.trim().isEmpty ? null : _specialCtrl.text.trim(),
      guestFullName:  '${_firstCtrl.text.trim()} ${_lastCtrl.text.trim()}',
      guestEmail:     _emailCtrl.text.trim().isEmpty  ? null : _emailCtrl.text.trim(),
      guestPhone:     _phoneCtrl.text.trim().isEmpty  ? null : _phoneCtrl.text.trim(),
      nationalIdFront: _idFrontB64,
      nationalIdBack:  _idBackB64,
    );

    if (!ok1 || !mounted) {
      setState(() => _submitting = false);
      if (mounted) showError(context, bp.error ?? 'Booking failed');
      return;
    }

    final bookingId = bp.lastBookingId!;

    // Step 2: POST /payments/initiate  { booking_id, method }
    final paymentId = await bp.initiatePayment(bookingId, _payMethod);

    if (paymentId == null || !mounted) {
      setState(() => _submitting = false);
      if (mounted) showError(context, 'Payment initiation failed');
      return;
    }

    // Step 3: POST /payments/:id/submit  { transaction_id, screenshot_url }
    final ok3 = await bp.submitPayment(
        paymentId, _txnCtrl.text.trim(), _screenshotB64!);

    setState(() => _submitting = false);
    if (!mounted) return;

    if (ok3) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(bookingId: bookingId)));
    } else {
      showError(context, bp.error ?? 'Payment submission failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp    = context.watch<HotelProvider>();
    final hotel = hp.hotel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text('Complete Booking',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        leading: _step == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppColors.textPrimary),
                onPressed: () => setState(() => _step = 1),
              ),
        actions: const [LangToggleLight(), SizedBox(width: 4)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _StepBar(step: _step, hotel: hotel, total: _total),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(
            begin: Offset(_step == 1 ? -0.04 : 0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: _step == 1
            ? _Step1Body(
                key: const ValueKey(1),
                formKey: _formKey1,
                firstCtrl: _firstCtrl, lastCtrl: _lastCtrl,
                emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl,
                natCtrl: _natCtrl, specialCtrl: _specialCtrl,
                adults: _adults, children: _children,
                capacity: _capacity, rooms: widget.rooms,
                roomName: widget.roomName,
                checkIn: widget.checkIn, checkOut: widget.checkOut,
                nights: widget.nights, total: _total,
                unitPrice: widget.roomPrice,
                idFrontB64: _idFrontB64, idBackB64: _idBackB64,
                uploadingFront: _uploadingFront, uploadingBack: _uploadingBack,
                onAdults: (v) => setState(() => _adults = v),
                onChildren: (v) => setState(() => _children = v),
                onPickFront: _pickFront, onPickBack: _pickBack,
                onNext: _goStep2,
              )
            : _Step2Body(
                key: const ValueKey(2),
                hotel: hotel,
                payMethods: _payMethods,
                payMethodsLoading: _loadingPayMethods,
                selectedMethod: _payMethod,
                txnCtrl: _txnCtrl,
                screenshotB64: _screenshotB64,
                uploadingShot: _uploadingShot,
                submitting: _submitting,
                total: _total,
                nights: widget.nights, rooms: widget.rooms,
                roomName: widget.roomName,
                checkIn: widget.checkIn, checkOut: widget.checkOut,
                adults: _adults, children: _children,
                guestName: '${_firstCtrl.text.trim()} ${_lastCtrl.text.trim()}',
                managerName:  _managerName,
                managerPhone: _managerPhone,
                managerEmail: _managerEmail,
                onMethodChanged: (m) => setState(() => _payMethod = m),
                onPickShot: _pickShot,
                onSubmit: _submit,
              ),
      ),
    );
  }
}

// ── Step indicator bar ────────────────────────────────────────────────────────
class _StepBar extends StatelessWidget {
  final int step;
  final Hotel? hotel;
  final double total;
  const _StepBar({required this.step, required this.hotel, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        _pill(1, 'Your Details', Icons.person_outline_rounded),
        Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 4),
            color: step > 1 ? AppColors.success : AppColors.border)),
        _pill(2, 'Payment', Icons.credit_card_rounded),
        const Spacer(),
        if (hotel != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hotel!.thumbnailUrl != null
                ? CachedNetworkImage(imageUrl: hotel!.thumbnailUrl!, width: 34, height: 34, fit: BoxFit.cover)
                : Container(width: 34, height: 34, color: AppColors.surfaceGray,
                    child: const Icon(Icons.hotel_outlined, size: 18, color: AppColors.textHint)),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            Text(hotel!.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('ETB ${_fmt(total)}',
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w800)),
          ]),
        ],
      ]),
    );
  }

  Widget _pill(int num, String label, IconData icon) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: step == num ? AppColors.primary : step > num ? AppColors.successLight : AppColors.surfaceGray,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(step > num ? Icons.check_rounded : icon, size: 13,
          color: step == num ? Colors.white : step > num ? AppColors.success : AppColors.textHint),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: step == num ? Colors.white : step > num ? AppColors.success : AppColors.textHint)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════
// STEP 1 — Guest Details
// ══════════════════════════════════════════════════════════════════════
class _Step1Body extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstCtrl, lastCtrl, emailCtrl, phoneCtrl, natCtrl, specialCtrl;
  final int adults, children, capacity, rooms, nights;
  final String roomName, checkIn, checkOut;
  final double total, unitPrice;
  final String? idFrontB64, idBackB64;
  final bool uploadingFront, uploadingBack;
  final ValueChanged<int> onAdults, onChildren;
  final VoidCallback onPickFront, onPickBack, onNext;

  const _Step1Body({
    super.key,
    required this.formKey, required this.firstCtrl, required this.lastCtrl,
    required this.emailCtrl, required this.phoneCtrl, required this.natCtrl,
    required this.specialCtrl, required this.adults, required this.children,
    required this.capacity, required this.rooms, required this.nights,
    required this.roomName, required this.checkIn, required this.checkOut,
    required this.total, required this.unitPrice,
    this.idFrontB64, this.idBackB64,
    required this.uploadingFront, required this.uploadingBack,
    required this.onAdults, required this.onChildren,
    required this.onPickFront, required this.onPickBack, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(children: [

          // ── Summary banner ───────────────────────────────────────────────
          _Banner(checkIn: checkIn, checkOut: checkOut, nights: nights,
              roomName: roomName, rooms: rooms, total: total, unitPrice: unitPrice),
          const SizedBox(height: 16),

          // ── Personal Info ────────────────────────────────────────────────
          _Section(icon: Icons.person_outline_rounded, title: 'Personal Information',
            child: Column(children: [
              Row(children: [
                Expanded(child: _F('First Name', firstCtrl, 'Abebe', req: true,
                    v: V.name)),
                const SizedBox(width: 12),
                Expanded(child: _F('Last Name', lastCtrl, 'Kebede', req: true,
                    v: V.name)),
              ]),
              const SizedBox(height: 14),
              _F('Email', emailCtrl, 'you@email.com',
                  type: TextInputType.emailAddress, icon: Icons.mail_outline_rounded,
                  helper: 'Required if no phone',
                  v: (s) {
                    if (s == null || s.trim().isEmpty) return null;
                    return V.email(s, required: false);
                  }),
              const SizedBox(height: 14),
              _F('Phone', phoneCtrl, '0912345678',
                  type: TextInputType.phone, icon: Icons.phone_outlined,
                  helper: 'e.g. 0912345678',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  v: V.phoneOptional),
              const SizedBox(height: 14),
              _F('Nationality', natCtrl, 'Ethiopian (optional)', icon: Icons.public_outlined),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Stay details ─────────────────────────────────────────────────
          _Section(icon: Icons.calendar_month_rounded, title: 'Stay Details',
            child: Column(children: [
              // Locked rooms banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.bed_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$rooms room${rooms > 1 ? "s" : ""} selected'
                        '${roomName.isNotEmpty ? " — $roomName" : ""}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text('Max capacity: $capacity guests',
                        style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Locked', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // Adults + Children
              Row(children: [
                Expanded(child: _Stepper(
                  label: 'Adults', value: adults, min: 1,
                  max: (capacity - children).clamp(1, 99),
                  onChanged: onAdults,
                )),
                const SizedBox(width: 12),
                Expanded(child: _Stepper(
                  label: 'Children', value: children, min: 0,
                  max: (capacity - adults).clamp(0, 99),
                  onChanged: onChildren,
                )),
              ]),
              const SizedBox(height: 10),

              // Capacity bar
              _CapBar(adults: adults, children: children, capacity: capacity),
              const SizedBox(height: 14),

              // Special requests
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Special Requests',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: specialCtrl, maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Early check-in, dietary needs, room preferences…',
                    hintStyle: TextStyle(fontSize: 12)),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // ── National ID ──────────────────────────────────────────────────
          _Section(icon: Icons.badge_outlined, title: 'National ID / Passport',
            subtitle: 'Required for check-in verification (front & back)',
            child: Row(children: [
              Expanded(child: _IdBox(label: 'Front *', b64: idFrontB64, uploading: uploadingFront, onTap: onPickFront)),
              const SizedBox(width: 12),
              Expanded(child: _IdBox(label: 'Back *', b64: idBackB64, uploading: uploadingBack, onTap: onPickBack)),
            ]),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text('Continue to Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// STEP 2 — Payment
// ══════════════════════════════════════════════════════════════════════
class _Step2Body extends StatelessWidget {
  final Hotel? hotel;
  final List<PaymentMethod> payMethods;
  final bool    payMethodsLoading;
  final String  selectedMethod;
  final TextEditingController txnCtrl;
  final String? screenshotB64;
  final bool    uploadingShot, submitting;
  final double  total;
  final int     nights, rooms, adults, children;
  final String  roomName, checkIn, checkOut, guestName;
  // Manager contact
  final String? managerName;
  final String? managerPhone;
  final String? managerEmail;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback onPickShot, onSubmit;

  const _Step2Body({
    super.key,
    required this.hotel,
    required this.payMethods,
    this.payMethodsLoading = false,
    required this.selectedMethod,
    required this.txnCtrl,
    this.screenshotB64,
    required this.uploadingShot,
    required this.submitting,
    required this.total,
    required this.nights,
    required this.rooms,
    required this.adults,
    required this.children,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.guestName,
    this.managerName,
    this.managerPhone,
    this.managerEmail,
    required this.onMethodChanged,
    required this.onPickShot,
    required this.onSubmit,
  });

  PaymentMethod? get _sel =>
      payMethods.where((m) => m.method == selectedMethod).firstOrNull;

  void _copy(BuildContext ctx, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccess(ctx, '$label copied!');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(children: [

        // ── Booking summary ──────────────────────────────────────────────
        _SummaryCard(hotel: hotel, roomName: roomName,
            checkIn: checkIn, checkOut: checkOut,
            nights: nights, adults: adults, total: total),
        const SizedBox(height: 14),

        // ── Manager contact (shown before payment methods) ───────────────
        if (managerName != null || managerPhone != null) ...[
          _Section(
            icon:  Icons.support_agent_rounded,
            title: 'Hotel Manager',
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        managerName?.isNotEmpty == true
                            ? managerName![0].toUpperCase() : 'M',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (managerName != null)
                      Text(managerName!,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 15, fontWeight: FontWeight.w800)),
                    const Text('Hotel Manager',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ])),
                ]),
                if (managerPhone != null && managerPhone!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _copy(context, managerPhone!, 'Phone'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25))),
                      child: Row(children: [
                        const Icon(Icons.phone_rounded,
                            size: 15, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(child: Text(managerPhone!,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 15, fontWeight: FontWeight.w800,
                                fontFamily: 'monospace', letterSpacing: 1))),
                        const Icon(Icons.copy_rounded,
                            size: 14, color: Colors.white60),
                        const SizedBox(width: 4),
                        const Text('Copy', style: TextStyle(
                            color: Colors.white60, fontSize: 10,
                            fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
                if (managerEmail != null && managerEmail!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _copy(context, managerEmail!, 'Email'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2))),
                      child: Row(children: [
                        const Icon(Icons.email_outlined,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(child: Text(managerEmail!,
                            style: const TextStyle(color: Colors.white70,
                                fontSize: 12))),
                        Icon(Icons.copy_rounded,
                            size: 13, color: Colors.white.withOpacity(0.5)),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                const Text(
                  '💬 Contact the manager if you need help with your booking.',
                  style: TextStyle(color: Colors.white60, fontSize: 11,
                      height: 1.4),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Payment method grid ──────────────────────────────────────────
        _Section(icon: Icons.credit_card_rounded, title: "Choose How You'll Pay",
          child: payMethodsLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.primary),
                    SizedBox(height: 14),
                    Text('Loading payment methods…',
                        style: TextStyle(fontSize: 13,
                            color: AppColors.textSecondary)),
                  ]),
                )
              : payMethods.isEmpty
              ? const _NoPay()
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Info row
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${payMethods.length} payment method${payMethods.length > 1 ? "s" : ""} available for this hotel',
                          style: const TextStyle(fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                  ),
                  Wrap(spacing: 8, runSpacing: 8,
                      children: payMethods.map((pm) {
                    final meta = _pmMeta[pm.method] ??
                        {'label': pm.method, 'emoji': '🏦', 'color': AppColors.primary};
                    final sel  = selectedMethod == pm.method;
                    final col  = meta['color'] as Color;
                    final w    = (MediaQuery.of(context).size.width - 64) / 3;
                    return GestureDetector(
                      onTap: () => onMethodChanged(pm.method),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: w,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: sel ? col.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: sel ? col : AppColors.border,
                              width: sel ? 2 : 1),
                          boxShadow: sel
                              ? [BoxShadow(
                                  color: col.withOpacity(0.2),
                                  blurRadius: 8)]
                              : null,
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Stack(alignment: Alignment.topRight, children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                  color: col.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text(
                                  meta['emoji'] as String,
                                  style: const TextStyle(fontSize: 18))),
                            ),
                            if (sel)
                              Positioned(
                                top: 0, right: 0,
                                child: Container(
                                  width: 14, height: 14,
                                  decoration: BoxDecoration(
                                      color: col, shape: BoxShape.circle),
                                  child: const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 9),
                                ),
                              ),
                          ]),
                          const SizedBox(height: 5),
                          Text(meta['label'] as String,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? col : AppColors.textPrimary),
                              textAlign: TextAlign.center, maxLines: 2),
                          if (pm.phoneNumber != null &&
                              pm.phoneNumber!.isNotEmpty)
                            Text(pm.phoneNumber!,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textHint,
                                    fontFamily: 'monospace'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    );
                  }).toList()),
                ]),
        ),
        const SizedBox(height: 14),

        // Payment account details
        if (_sel != null) _PayDetails(pm: _sel!, total: total),
        const SizedBox(height: 14),

        // Upload proof
        if (selectedMethod.isNotEmpty)
          _Section(icon: Icons.upload_rounded, title: 'Upload Payment Proof',
            child: Column(children: [
              // Transaction ID
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _Lbl('Transaction ID / Reference', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: txnCtrl,
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    hintText: 'e.g. TXN123456789',
                    helperText: 'Reference shown in the transfer confirmation',
                    helperStyle: TextStyle(fontSize: 11),
                    prefixIcon: Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.tag_rounded, size: 16, color: AppColors.textHint)),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Screenshot
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _Lbl('Payment Screenshot', required: true),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: uploadingShot ? null : onPickShot,
                  child: Container(
                    width:  double.infinity,
                    height: screenshotB64 != null ? 190 : 120,
                    decoration: BoxDecoration(
                      color: screenshotB64 != null
                          ? AppColors.successLight
                          : AppColors.surfaceGray,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: screenshotB64 != null
                            ? AppColors.success
                            : AppColors.border,
                        width: screenshotB64 != null ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: uploadingShot
                        ? const Center(child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary),
                              SizedBox(height: 10),
                              Text('Uploading…',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ))
                        : screenshotB64 != null
                            ? _ScreenshotPreview(b64: screenshotB64!)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined,
                                      size: 36, color: AppColors.primary),
                                  SizedBox(height: 8),
                                  Text('Tap to upload screenshot',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary)),
                                  SizedBox(height: 4),
                                  Text('PNG or JPG — transfer confirmation',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint)),
                                ],
                              ),
                  ),
                ),
              ]),
            ]),
          ),
        const SizedBox(height: 14),

        // Final summary
        _FinalSummary(hotel: hotel, guestName: guestName, checkIn: checkIn,
            checkOut: checkOut, nights: nights, rooms: rooms, roomName: roomName,
            adults: adults, children: children, payMethod: selectedMethod, total: total),
        const SizedBox(height: 20),

        // Submit button
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: submitting ? null : onSubmit,
            icon: submitting
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Icon(Icons.check_rounded, size: 20),
            label: Text(
              submitting ? 'Processing…' : 'Confirm & Submit — ETB ${_fmt(total)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  const _Section({required this.icon, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ]),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
      ],
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _Banner extends StatelessWidget {
  final String checkIn, checkOut, roomName;
  final int nights, rooms;
  final double total, unitPrice;
  const _Banner({required this.checkIn, required this.checkOut, required this.roomName,
    required this.nights, required this.rooms, required this.total, required this.unitPrice});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (roomName.isNotEmpty) Row(children: [
          const Icon(Icons.bed_outlined, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(roomName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text('$checkIn → $checkOut · $nights ${nights > 1 ? "nights" : "night"}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('ETB ${_fmt(total)}',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        Text('ETB ${_fmt(unitPrice)} × $nights nts × $rooms rm',
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ]),
    ]),
  );
}

class _Lbl extends StatelessWidget {
  final String text;
  final bool required;
  const _Lbl(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      children: required ? const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))] : [],
    ),
  );
}

class _F extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final TextInputType type;
  final IconData? icon;
  final String? helper;
  final bool req;
  final String? Function(String?)? v;
  final List<TextInputFormatter>? inputFormatters;

  const _F(this.label, this.ctrl, this.hint, {
    this.type = TextInputType.text, this.icon, this.helper,
    this.req = false, this.v, this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Lbl(label, required: req),
    const SizedBox(height: 6),
    TextFormField(
      controller:  ctrl,
      keyboardType: type,
      validator:   v,
      inputFormatters: inputFormatters,
      autovalidateMode: v != null
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText:    hint,
        helperText:  helper,
        helperStyle: const TextStyle(fontSize: 11),
        errorStyle:  const TextStyle(fontSize: 11, color: AppColors.error),
        prefixIcon: icon != null ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(icon, size: 16, color: AppColors.textHint)) : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    ),
  ]);
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.label, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    const SizedBox(height: 6),
    Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        _Btn(Icons.remove_rounded, value > min ? () => onChanged(value - 1) : null),
        Expanded(child: Center(child: Text('$value',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)))),
        _Btn(Icons.add_rounded, value < max ? () => onChanged(value + 1) : null),
      ]),
    ),
  ]);

  Widget _Btn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: SizedBox(width: 44, height: 44,
        child: Icon(icon, size: 20, color: onTap != null ? AppColors.textSecondary : AppColors.border)),
  );
}

class _CapBar extends StatelessWidget {
  final int adults, children, capacity;
  const _CapBar({required this.adults, required this.children, required this.capacity});

  @override
  Widget build(BuildContext context) {
    final total   = adults + children;
    final over    = total > capacity;
    final pct     = (total / capacity.clamp(1, 999)).clamp(0.0, 1.0);
    final bgColor = over ? AppColors.errorLight : AppColors.successLight;
    final fgColor = over ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.people_outline_rounded, size: 14, color: fgColor),
          const SizedBox(width: 6),
          Text(over ? 'Exceeds capacity! Max $capacity guests' : 'Guests: $total / $capacity ✓',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fgColor)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 4,
            backgroundColor: fgColor.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(fgColor),
          ),
        ),
      ]),
    );
  }
}

class _IdBox extends StatelessWidget {
  final String     label;
  final String?    b64;
  final bool       uploading;
  final VoidCallback onTap;

  const _IdBox({
    required this.label,
    this.b64,
    required this.uploading,
    required this.onTap,
  });

  /// Safely decode base64 string (with or without data: prefix)
  static Uint8List? _decodeB64(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final str = raw.contains(',') ? raw.split(',').last : raw;
      // Remove whitespace/newlines that cause decode failures
      final clean = str.replaceAll(RegExp(r'\s'), '');
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes  = _decodeB64(b64);
    final hasImg = bytes != null && bytes.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        children: label.contains('*')
            ? [] // already has asterisk
            : [const TextSpan(text: ' (optional)',
                style: TextStyle(fontSize: 10, color: AppColors.textHint,
                    fontWeight: FontWeight.w400))],
      )),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: uploading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 110,
          decoration: BoxDecoration(
            color:        hasImg ? AppColors.successLight : AppColors.surfaceGray,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasImg ? AppColors.success : AppColors.border,
              width: hasImg ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: uploading
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5,
                          color: AppColors.primary)),
                    SizedBox(height: 8),
                    Text('Uploading…',
                        style: TextStyle(fontSize: 11,
                            color: AppColors.textSecondary)),
                  ]))
              : hasImg
                  ? Stack(fit: StackFit.expand, children: [
                      // Show the image with error handling
                      Image.memory(
                        bytes,
                        fit:          BoxFit.cover,
                        errorBuilder: (_, err, __) => Container(
                          color: AppColors.successLight,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_rounded,
                                  color: AppColors.success, size: 36),
                              SizedBox(height: 6),
                              Text('Image attached',
                                  style: TextStyle(fontSize: 11,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700)),
                            ]),
                        ),
                      ),
                      // Success overlay at bottom
                      Positioned(bottom: 0, left: 0, right: 0,
                        child: Container(
                          color: AppColors.success.withOpacity(0.88),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text('ID Attached ✓',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                      // Tap to change overlay
                      Positioned(top: 6, right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text('Tap to change',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                        )),
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
                            style: TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        const Text('JPG, PNG or PDF',
                            style: TextStyle(fontSize: 10,
                                color: AppColors.textHint)),
                      ],
                    ),
        ),
      ),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final Hotel? hotel;
  final String roomName, checkIn, checkOut;
  final int nights, adults;
  final double total;
  const _SummaryCard({required this.hotel, required this.roomName, required this.checkIn,
    required this.checkOut, required this.nights, required this.adults, required this.total});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 56, height: 56,
          child: hotel?.thumbnailUrl != null
              ? CachedNetworkImage(imageUrl: hotel!.thumbnailUrl!, fit: BoxFit.cover)
              : Container(color: AppColors.surfaceGray, child: const Icon(Icons.hotel_outlined, color: AppColors.textHint))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(hotel?.name ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        if (roomName.isNotEmpty) Row(children: [
          const Icon(Icons.bed_outlined, size: 11, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(roomName, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ]),
        Text('$checkIn → $checkOut · ${nights}N · $adults adults',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('ETB ${_fmt(total)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const Text('Total', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
      ]),
    ]),
  );
}

class _PayDetails extends StatelessWidget {
  final PaymentMethod pm;
  final double total;
  const _PayDetails({required this.pm, required this.total});

  void _copyVal(BuildContext ctx, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccess(ctx, '$label copied!');
  }

  @override
  Widget build(BuildContext context) {
    final meta  = _pmMeta[pm.method] ?? {'label': pm.method, 'emoji': '🏦', 'color': AppColors.primary};
    final color = meta['color'] as Color;

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          color: color.withOpacity(0.1),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(meta['emoji'] as String, style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(meta['label'] as String,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
              Text('Send ETB ${_fmt(total)} to the account below',
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
            ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            if (pm.accountName != null) _row(context, 'Account Name', pm.accountName!, color),
            if (pm.phoneNumber != null && pm.phoneNumber!.isNotEmpty) ...[
              if (pm.accountName != null) const SizedBox(height: 8),
              _bigRow(context, 'Phone / Wallet Number', pm.phoneNumber!, color),
            ],
            if (pm.accountNumber != null && pm.accountNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _bigRow(context, 'Account Number', pm.accountNumber!, color),
            ],
            if (pm.instructions != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.15))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(pm.instructions!,
                      style: TextStyle(fontSize: 12, color: color, height: 1.5))),
                ]),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A))),
              child: Row(children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(child: RichText(text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  children: [
                    const TextSpan(text: 'Send exactly '),
                    TextSpan(text: 'ETB ${_fmt(total)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    const TextSpan(text: '. Include your booking reference in the transfer note.'),
                  ],
                ))),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _row(BuildContext ctx, String label, String value, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.15))),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color.withOpacity(0.6), letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          ])),
          IconButton(icon: Icon(Icons.copy_rounded, size: 16, color: color), onPressed: () => _copyVal(ctx, value, label)),
        ]),
      );

  Widget _bigRow(BuildContext ctx, String label, String value, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25), width: 2)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color.withOpacity(0.6), letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace', letterSpacing: 2)),
          ])),
          Column(children: [
            IconButton(icon: Icon(Icons.copy_rounded, size: 20, color: color), onPressed: () => _copyVal(ctx, value, label)),
            Text('Copy', style: TextStyle(fontSize: 9, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
          ]),
        ]),
      );
}

class _FinalSummary extends StatelessWidget {
  final Hotel? hotel;
  final String guestName, checkIn, checkOut, roomName, payMethod;
  final int nights, rooms, adults, children;
  final double total;
  const _FinalSummary({required this.hotel, required this.guestName, required this.checkIn,
    required this.checkOut, required this.roomName, required this.payMethod,
    required this.nights, required this.rooms, required this.adults,
    required this.children, required this.total});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFECFDF5), Color(0xFFEFF6FF)]),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.success.withOpacity(0.2)),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(hotel?.name ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text('$checkIn → $checkOut · $nights nights', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text('$guestName · $adults adult${adults > 1 ? "s" : ""}${children > 0 ? " · $children children" : ""}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        if (roomName.isNotEmpty)
          Text('${rooms}× $roomName', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
        if (payMethod.isNotEmpty)
          Text(_pmMeta[payMethod]?['label']?.toString() ?? payMethod,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('ETB ${_fmt(total)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        Text('$nights nights · $rooms rm', style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ]),
    ]),
  );
}

class _NoPay extends StatelessWidget {
  const _NoPay();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(24),
    child: Column(children: [
      Icon(Icons.credit_card_off_outlined, size: 36, color: AppColors.textHint),
      SizedBox(height: 12),
      Text('No payment methods configured for this hotel.',
          textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      SizedBox(height: 4),
      Text('Contact the hotel directly to arrange payment.',
          textAlign: TextAlign.center, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREENSHOT PREVIEW — safe base64 image display with full error handling
// ─────────────────────────────────────────────────────────────────────────────
class _ScreenshotPreview extends StatelessWidget {
  final String b64;
  const _ScreenshotPreview({required this.b64});

  Uint8List? _decode() {
    try {
      final raw   = b64.contains(',') ? b64.split(',').last : b64;
      final clean = raw.replaceAll(RegExp(r'\s'), '');
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode();
    return Stack(fit: StackFit.expand, children: [
      // Image display
      bytes != null
          ? Image.memory(bytes, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback())
          : _fallback(),

      // Green success overlay at bottom
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: Container(
          color: AppColors.success.withOpacity(0.88),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Screenshot attached ✓',
                  style: TextStyle(
                      color:      Colors.white,
                      fontSize:   13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),

      // "Tap to change" badge top-right
      Positioned(
        top: 8, right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color:        Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(10)),
          child: const Text('Tap to change',
              style: TextStyle(
                  color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }

  Widget _fallback() => Container(
    color: AppColors.successLight,
    child: const Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Icon(Icons.image_rounded, color: AppColors.success, size: 44),
      SizedBox(height: 8),
      Text('Screenshot saved',
          style: TextStyle(
              color:      AppColors.success,
              fontSize:   13,
              fontWeight: FontWeight.w700)),
      SizedBox(height: 4),
      Text('Image attached successfully',
          style: TextStyle(fontSize: 11, color: AppColors.success)),
    ]),
  );
}
