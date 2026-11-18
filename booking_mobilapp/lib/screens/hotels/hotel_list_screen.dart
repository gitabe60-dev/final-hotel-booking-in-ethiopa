import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hotel.dart';
import '../../models/search_params.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/hotel_card.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/empty_state.dart';
import 'hotel_detail_screen.dart';

class HotelListScreen extends StatefulWidget {
  final HotelSearchParams? initialParams;
  const HotelListScreen({super.key, this.initialParams});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  final _nameCtrl     = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

  String  _city      = '';
  String  _type      = '';
  String  _sort      = 'rating';
  double? _minRating;
  bool    _showFilters = false;
  bool    _initialized = false;
  static const int _limit = 12;

  static const _types = <String>['hotel', 'resort', 'boutique', 'lodge'];
  static const _ratings = <double>[3.0, 3.5, 4.0, 4.5];
  static const _sorts = <Map<String, String>>[
    {'label': 'Best Rating',  'value': 'rating'},
    {'label': 'Price ↑',      'value': 'price_asc'},
    {'label': 'Price ↓',      'value': 'price_desc'},
    {'label': 'Name A–Z',     'value': 'name'},
    {'label': 'Most Reviews', 'value': 'review_count'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialParams;
    if (p != null) {
      _nameCtrl.text = p.name ?? '';
      _city          = p.city ?? '';
      _type          = p.type ?? '';
      _sort          = p.sort;
      _minRating     = p.minRating;
      if (p.minPrice != null) {
        _minPriceCtrl.text = p.minPrice!.toStringAsFixed(0);
      }
      if (p.maxPrice != null) {
        _maxPriceCtrl.text = p.maxPrice!.toStringAsFixed(0);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        _doSearch(0);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  HotelSearchParams _buildParams(int offset) => HotelSearchParams(
        name:      _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        city:      _city.isEmpty      ? null : _city,
        type:      _type.isEmpty      ? null : _type,
        minPrice:  _minPriceCtrl.text.isEmpty
            ? null
            : double.tryParse(_minPriceCtrl.text),
        maxPrice:  _maxPriceCtrl.text.isEmpty
            ? null
            : double.tryParse(_maxPriceCtrl.text),
        minRating: _minRating,
        sort:      _sort,
        limit:     _limit,
        offset:    offset,
      );

  Future<void> _doSearch(int offset) async {
    await context.read<HotelProvider>().search(params: _buildParams(offset));
  }

  void _clearFilters() {
    setState(() {
      _nameCtrl.clear();
      _minPriceCtrl.clear();
      _maxPriceCtrl.clear();
      _city      = '';
      _type      = '';
      _sort      = 'rating';
      _minRating = null;
    });
    _doSearch(0);
  }

  bool get _hasFilters =>
      _nameCtrl.text.isNotEmpty ||
      _city.isNotEmpty ||
      _type.isNotEmpty ||
      _minPriceCtrl.text.isNotEmpty ||
      _maxPriceCtrl.text.isNotEmpty ||
      _minRating != null;

  @override
  Widget build(BuildContext context) {
    final hp     = context.watch<HotelProvider>();
    final offset = hp.params.offset;
    final total  = hp.total;
    final pages  = total == 0 ? 1 : (total / _limit).ceil();
    final page   = offset ~/ _limit + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(
        title:    AppLocalizations.of(context).t('explore_hotels'),
        showBack: Navigator.canPop(context),
      ),
      body: Column(children: [

        // ── Search + filters bar ────────────────────────────────────────
        _SearchFilterBar(
          nameCtrl:        _nameCtrl,
          cities:          hp.cities,
          selectedCity:    _city,
          onCityChanged:   (c) { setState(() => _city = c ?? ''); _doSearch(0); },
          showFilters:     _showFilters,
          hasFilters:      _hasFilters,
          onToggleFilters: () => setState(() => _showFilters = !_showFilters),
          onSearch:        () => _doSearch(0),
          onClear:         _hasFilters ? _clearFilters : null,
          type:            _type,
          onTypeChanged:   (v) => setState(() => _type = v ?? ''),
          minPriceCtrl:    _minPriceCtrl,
          maxPriceCtrl:    _maxPriceCtrl,
          minRating:       _minRating,
          onRatingChanged: (v) => setState(() => _minRating = v),
          sort:            _sort,
          onSortChanged:   (v) => setState(() => _sort = v ?? 'rating'),
          types:           _types,
          ratings:         _ratings,
          sorts:           _sorts,
        ),

        // ── Result count ────────────────────────────────────────────────
        Container(
          color:   Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(children: [
            hp.listLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: '$total ',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      TextSpan(
                          text: 'hotel${total != 1 ? "s" : ""} found',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      if (_city.isNotEmpty)
                        TextSpan(
                            text: ' in $_city',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                    ]),
                  ),
            const Spacer(),
            if (!hp.listLoading && pages > 1)
              Text('$page / $pages',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textHint)),
          ]),
        ),
        const Divider(height: 1),

        // ── Hotel grid ──────────────────────────────────────────────────
        Expanded(
          child: hp.listLoading
              ? const Center(child: AppSpinner(size: SpinnerSize.large))
              : hp.hotels.isEmpty
                  ? EmptyState(
                      title:       'No hotels found',
                      subtitle:    'Try different keywords or clear the filters',
                      icon:        Icons.hotel_outlined,
                      actionLabel: _hasFilters ? 'Clear Filters' : null,
                      onAction:    _hasFilters ? _clearFilters : null,
                    )
                  : RefreshIndicator(
                      onRefresh: () => _doSearch(offset),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(14),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:   2,
                          childAspectRatio: 0.63,
                          crossAxisSpacing: 10,
                          mainAxisSpacing:  10,
                        ),
                        itemCount: hp.hotels.length,
                        itemBuilder: (ctx, i) {
                          final h = hp.hotels[i];
                          return HotelCard(
                            hotel:   h,
                            compact: true,
                            onTap:   () => Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        HotelDetailScreen(hotelId: h.id))),
                          );
                        },
                      ),
                    ),
        ),

        // ── Pagination ──────────────────────────────────────────────────
        if (!hp.listLoading && total > _limit)
          _PaginationBar(
            page:   page,
            pages:  pages,
            onPrev: offset > 0 ? () => _doSearch(offset - _limit) : null,
            onNext: offset + _limit < total
                ? () => _doSearch(offset + _limit)
                : null,
          ),
        ]),
      );
    }
  }

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH + FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────
class _SearchFilterBar extends StatelessWidget {
  final TextEditingController nameCtrl;
  final List<City>            cities;
  final String                selectedCity;
  final ValueChanged<String?> onCityChanged;
  final bool                  showFilters;
  final bool                  hasFilters;
  final VoidCallback          onToggleFilters;
  final VoidCallback          onSearch;
  final VoidCallback?         onClear;
  // Filter state
  final String                type;
  final ValueChanged<String?> onTypeChanged;
  final TextEditingController minPriceCtrl;
  final TextEditingController maxPriceCtrl;
  final double?               minRating;
  final ValueChanged<double?> onRatingChanged;
  final String                sort;
  final ValueChanged<String?> onSortChanged;
  final List<String>          types;
  final List<double>          ratings;
  final List<Map<String, String>> sorts;

  const _SearchFilterBar({
    required this.nameCtrl,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
    required this.showFilters,
    required this.hasFilters,
    required this.onToggleFilters,
    required this.onSearch,
    this.onClear,
    required this.type,
    required this.onTypeChanged,
    required this.minPriceCtrl,
    required this.maxPriceCtrl,
    required this.minRating,
    required this.onRatingChanged,
    required this.sort,
    required this.onSortChanged,
    required this.types,
    required this.ratings,
    required this.sorts,
  });

  InputDecoration _fd(String label) => InputDecoration(
        labelText:  label,
        labelStyle: const TextStyle(fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(children: [
        // ── Row 1: name search + city dropdown + filter btn + search btn ──
        Row(children: [
          // Name input
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 42,
              child: TextField(
                controller:  nameCtrl,
                onSubmitted: (_) => onSearch(),
                style:       const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText:  'Hotel name…',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: AppColors.textHint),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // City dropdown
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 42,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border:        Border.all(color: AppColors.border),
                  borderRadius:  BorderRadius.circular(10),
                  color:         Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCity.isEmpty ? '' : selectedCity,
                    onChanged: onCityChanged,
                    isExpanded: true,
                    isDense:    true,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textPrimary),
                    icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16, color: AppColors.textHint),
                    hint: const Text('City',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textHint)),
                    items: [
                      const DropdownMenuItem(
                          value: '',
                          child: Text('All Cities',
                              style: TextStyle(fontSize: 12))),
                      ...cities.map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Filter toggle
          _IconBtn(
            icon:    Icons.tune_rounded,
            active:  showFilters,
            badge:   hasFilters,
            onTap:   onToggleFilters,
            tooltip: 'Filters',
          ),
          const SizedBox(width: 6),

          // Search
          _IconBtn(
            icon:    Icons.search_rounded,
            active:  true,
            solid:   true,
            onTap:   onSearch,
            tooltip: 'Search',
          ),

          // Clear
          if (onClear != null) ...[
            const SizedBox(width: 6),
            _IconBtn(
              icon:    Icons.close_rounded,
              active:  false,
              onTap:   onClear!,
              tooltip: 'Clear',
            ),
          ],
        ]),

        // ── Row 2: expanded filter panel ────────────────────────────────
        if (showFilters)
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve:    Curves.easeOut,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                // Type
                SizedBox(
                  width: 130, height: 40,
                  child: DropdownButtonFormField<String>(
                    value:     type.isEmpty ? '' : type,
                    decoration: _fd('Type'),
                    onChanged: onTypeChanged,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(
                          value: '',
                          child: Text('All Types',
                              style: TextStyle(fontSize: 12))),
                      ...types.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: const TextStyle(fontSize: 12)))),
                    ],
                  ),
                ),
                // Min price
                SizedBox(
                  width: 105, height: 40,
                  child: TextField(
                    controller:   minPriceCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12),
                    decoration:   _fd('Min ETB'),
                  ),
                ),
                // Max price
                SizedBox(
                  width: 105, height: 40,
                  child: TextField(
                    controller:   maxPriceCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12),
                    decoration:   _fd('Max ETB'),
                  ),
                ),
                // Rating
                SizedBox(
                  width: 115, height: 40,
                  child: DropdownButtonFormField<double>(
                    value:     minRating,
                    decoration: _fd('Min Rating'),
                    onChanged: onRatingChanged,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem<double>(
                          value: null,
                          child: Text('Any ★',
                              style: TextStyle(fontSize: 12))),
                      ...ratings.map((r) => DropdownMenuItem(
                          value: r,
                          child: Text('★ $r+',
                              style: const TextStyle(fontSize: 12)))),
                    ],
                  ),
                ),
                // Sort
                SizedBox(
                  width: 130, height: 40,
                  child: DropdownButtonFormField<String>(
                    value:     sort,
                    decoration: _fd('Sort By'),
                    onChanged: onSortChanged,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textPrimary),
                    items: sorts
                        .map((s) => DropdownMenuItem(
                            value: s['value'],
                            child: Text(s['label']!,
                                style: const TextStyle(fontSize: 12))))
                        .toList(),
                  ),
                ),
                // Apply button
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: onSearch,
                    icon:  const Icon(Icons.check_rounded, size: 15),
                    label: const Text('Apply',
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ICON BUTTON HELPER
// ─────────────────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final bool         active;
  final bool         solid;
  final bool         badge;
  final VoidCallback onTap;
  final String?      tooltip;

  const _IconBtn({
    required this.icon,
    required this.active,
    required this.onTap,
    this.solid   = false,
    this.badge   = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final bg = solid
        ? AppColors.primary
        : (active ? AppColors.primary : Colors.white);
    final fg = (solid || active) ? Colors.white : AppColors.textSecondary;
    final bd = (solid || active) ? AppColors.primary : AppColors.border;

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color:        bg,
            border:       Border.all(color: bd),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(icon, size: 19, color: fg),
            if (badge)
              Positioned(
                top: 7, right: 7,
                child: Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGINATION BAR
// ─────────────────────────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int        page, pages;
  final VoidCallback? onPrev, onNext;

  const _PaginationBar(
      {required this.page,
      required this.pages,
      this.onPrev,
      this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _PageBtn(
          label: '← Prev',
          enabled: onPrev != null,
          onTap:   onPrev,
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8)),
          child: Text('$page / $pages',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ),
        const SizedBox(width: 16),
        _PageBtn(
          label:   'Next →',
          enabled: onNext != null,
          onTap:   onNext,
        ),
      ]),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String     label;
  final bool       enabled;
  final VoidCallback? onTap;
  const _PageBtn(
      {required this.label, required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color:        enabled ? Colors.white : AppColors.surfaceGray,
            borderRadius: BorderRadius.circular(8),
            border:       Border.all(
                color: enabled ? AppColors.border : AppColors.surfaceGray),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? AppColors.primary
                      : AppColors.textHint)),
        ),
      );
}
