import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laptop.dart';
import '../services/laptop_service.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'admin_screen.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const HomeScreen({super.key, required this.themeProvider});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _laptopService = LaptopService();

  List<Laptop> _laptops = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';

  String _selectedSort = 'Name (A-Z)';
  final _sortOptions = [
    'Name (A-Z)', 'Name (Z-A)',
    'Screen Size (Large→Small)', 'Screen Size (Small→Large)',
    'RAM (High→Low)', 'RAM (Low→High)',
    'SSD (High→Low)', 'SSD (Low→High)',
    'GPU VRAM (High→Low)', 'GPU VRAM (Low→High)',
    'Weight (Light→Heavy)', 'Weight (Heavy→Light)',
    'Thickness (Thin→Thick)', 'Thickness (Thick→Thin)',
  ];

  String? _filterBrand;
  String? _filterCpuBrand;
  String? _filterCpuSeries;
  String? _filterGpuBrand;
  String? _filterRamType;
  String? _filterStorageType;
  String? _filterResolution;
  String? _filterPanelType;
  int? _filterMinRamGb;
  int? _filterMaxRamGb;
  int? _filterMinStorageGb;
  double? _filterMinDisplayInch;
  double? _filterMaxDisplayInch;
  int? _filterMinRefreshRateHz;
  double? _filterMaxWeightKg;
  int? _filterMinBatteryWh;
  int? _filterMinVramGb;

  List<String> _brands = [];

  int _totalElements = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadData();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoriteIds') ?? [];
    setState(() {
      _favoriteIds = ids.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteIds', _favoriteIds.map((e) => '$e').toList());
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
    _saveFavorites();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      try {
        _brands = await _laptopService.getBrands();
      } catch (_) {
        _brands = [];
      }

      await _fetchLaptops();
    } catch (e) {
      setState(() { _errorMessage = 'Failed to load data: $e'; _isLoading = false; });
    }
  }

  Future<void> _fetchLaptops() async {
    setState(() { _isLoading = true; });
    try {
      String sortBy = 'id';
      String sortDir = 'asc';
      switch (_selectedSort) {
        case 'Name (A-Z)': sortBy = 'brand'; sortDir = 'asc'; break;
        case 'Name (Z-A)': sortBy = 'brand'; sortDir = 'desc'; break;
        case 'RAM (High→Low)': sortBy = 'ramCapacityGb'; sortDir = 'desc'; break;
        case 'RAM (Low→High)': sortBy = 'ramCapacityGb'; sortDir = 'asc'; break;
        case 'SSD (High→Low)': sortBy = 'storageCapacityGb'; sortDir = 'desc'; break;
        case 'SSD (Low→High)': sortBy = 'storageCapacityGb'; sortDir = 'asc'; break;
        case 'Weight (Light→Heavy)': sortBy = 'weightKg'; sortDir = 'asc'; break;
        case 'Weight (Heavy→Light)': sortBy = 'weightKg'; sortDir = 'desc'; break;
        case 'Thickness (Thin→Thick)': sortBy = 'thicknessMm'; sortDir = 'asc'; break;
        case 'Thickness (Thick→Thin)': sortBy = 'thicknessMm'; sortDir = 'desc'; break;
        default: sortBy = 'id'; sortDir = 'asc';
      }

      final result = await _laptopService.getLaptops(
        page: 0,
        size: 100,
        sortBy: sortBy,
        sortDir: sortDir,
        brand: _filterBrand,
        cpuBrand: _filterCpuBrand,
        cpuSeries: _filterCpuSeries,
        gpuBrand: _filterGpuBrand,
        ramType: _filterRamType,
        storageType: _filterStorageType,
        resolution: _filterResolution,
        panelType: _filterPanelType,
        minRamGb: _filterMinRamGb,
        maxRamGb: _filterMaxRamGb,
        minStorageGb: _filterMinStorageGb,
        minDisplayInch: _filterMinDisplayInch,
        maxDisplayInch: _filterMaxDisplayInch,
        minRefreshRateHz: _filterMinRefreshRateHz,
        maxWeightKg: _filterMaxWeightKg,
        minBatteryWh: _filterMinBatteryWh,
        minVramGb: _filterMinVramGb,
      );

      setState(() {
        _laptops = result.content;
        _totalElements = result.totalElements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = 'Failed to load laptops: $e'; _isLoading = false; });
    }
  }

  List<Laptop> get _filteredLaptops {
    if (_searchQuery.trim().isEmpty) return _laptops;
    final words = _searchQuery.toLowerCase().trim().split(RegExp(r'\s+'));
    return _laptops.where((l) {
      final txt = '${l.brand} ${l.series} ${l.cpuModelName} ${l.gpuModelName}'.toLowerCase();
      return words.every((w) => txt.contains(w));
    }).toList();
  }

  List<Laptop> get _sortedLaptops {
    final list = List<Laptop>.from(_filteredLaptops);
    switch (_selectedSort) {
      case 'Screen Size (Large→Small)': list.sort((a, b) => b.displaySizeInch.compareTo(a.displaySizeInch)); break;
      case 'Screen Size (Small→Large)': list.sort((a, b) => a.displaySizeInch.compareTo(b.displaySizeInch)); break;
      case 'GPU VRAM (High→Low)': list.sort((a, b) => (b.gpuVramGb ?? 0).compareTo(a.gpuVramGb ?? 0)); break;
      case 'GPU VRAM (Low→High)': list.sort((a, b) => (a.gpuVramGb ?? 0).compareTo(b.gpuVramGb ?? 0)); break;
    }
    return list;
  }

  void _resetFilters() {
    setState(() {
      _filterBrand = null;
      _filterCpuBrand = null;
      _filterCpuSeries = null;
      _filterGpuBrand = null;
      _filterRamType = null;
      _filterStorageType = null;
      _filterResolution = null;
      _filterPanelType = null;
      _filterMinRamGb = null;
      _filterMaxRamGb = null;
      _filterMinStorageGb = null;
      _filterMinDisplayInch = null;
      _filterMaxDisplayInch = null;
      _filterMinRefreshRateHz = null;
      _filterMaxWeightKg = null;
      _filterMinBatteryWh = null;
      _filterMinVramGb = null;
    });
    _fetchLaptops();
  }

  void _applyFilters() {
    Navigator.pop(context);
    _fetchLaptops();
  }

  void _showSortSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => AppTheme.glassContainer(
        context,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sort', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Flexible(child: ListView(shrinkWrap: true, children: _sortOptions.map((o) => ListTile(
              title: Text(o, style: TextStyle(color: _selectedSort == o ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
              leading: Icon(_selectedSort == o ? Icons.radio_button_checked : Icons.radio_button_off,
                color: _selectedSort == o ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
              dense: true,
              onTap: () {
                setState(() => _selectedSort = o);
                Navigator.pop(ctx);
                _fetchLaptops();
              },
            )).toList())),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laptops = _sortedLaptops;
    final btnStyle = OutlinedButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      side: BorderSide(color: Theme.of(context).dividerColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );

    return AppTheme.buildBackground(
      context,
      child: Scaffold(
        drawer: Drawer(
          width: 340,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _buildFilterDrawer(),
        ),
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Laptop Database', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.secondary)),
            Row(children: [
              IconButton(
                icon: Icon(Icons.light_mode, color: Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: () => widget.themeProvider.toggleTheme(),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurfaceVariant), tooltip: 'Admin Panel',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()))
                    .then((_) => _loadData()),
              ),
              IconButton(
                icon: Icon(Icons.favorite, color: Theme.of(context).colorScheme.error),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => FavoritesScreen(favoriteIds: _favoriteIds, onToggleFavorite: _toggleFavorite),
                )).then((_) => setState(() {})),
              ),
            ]),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(children: [
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search Laptop, CPU, GPU...', hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                filled: true, fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Builder(builder: (ctx) => OutlinedButton.icon(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: const Text('Filter'), style: btnStyle,
              ))),
              const SizedBox(width: 12),
              Expanded(child: Builder(builder: (ctx) => OutlinedButton.icon(
                onPressed: () => _showSortSheet(ctx),
                icon: const Icon(Icons.sort, size: 18),
                label: Text(_selectedSort, overflow: TextOverflow.ellipsis, maxLines: 1), style: btnStyle,
              ))),
            ]),
          ]),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Text(
            _isLoading ? 'Loading...' : '${laptops.length} / $_totalElements products listed',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        )),

        if (_isLoading)
          SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)))
        else if (_errorMessage != null)
          SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ])))
        else if (laptops.isEmpty)
          SliverFillRemaining(child: Center(child: Text('No results found.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16))))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverLayoutBuilder(builder: (context, constraints) {
              int cols = 4;
              if (constraints.crossAxisExtent < 600) cols = 1;
              else if (constraints.crossAxisExtent < 900) cols = 2;
              else if (constraints.crossAxisExtent < 1200) cols = 3;
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _HoverLaptopCard(
                    laptop: laptops[i],
                    isFavorite: _favoriteIds.contains(laptops[i].id),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        laptop: laptops[i],
                        isFavorite: _favoriteIds.contains(laptops[i].id),
                        onToggleFavorite: () => _toggleFavorite(laptops[i].id),
                      ),
                    )).then((_) => setState(() {})),
                  ),
                  childCount: laptops.length,
                ),
              );
            }),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ])),
    ));
  }

  Widget _buildFilterDrawer() {
    return AppTheme.glassContainer(
      context,
      borderRadius: 0,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 12, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Detailed Filters', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(onPressed: _resetFilters, child: const Text('Clear')),
          ]),
        ),
        Divider(color: Theme.of(context).dividerColor),
        Expanded(child: SingleChildScrollView(child: Column(children: [
          if (_brands.isNotEmpty)
            _dropdownFilter('Brand', _filterBrand, _brands, (v) => setState(() => _filterBrand = v)),

          _FilterInput(label: 'CPU Brand', initialValue: _filterCpuBrand, onChanged: (v) => setState(() => _filterCpuBrand = v.isEmpty ? null : v)),
          _FilterInput(label: 'CPU Series', initialValue: _filterCpuSeries, onChanged: (v) => setState(() => _filterCpuSeries = v.isEmpty ? null : v)),
          _FilterInput(label: 'GPU Brand', initialValue: _filterGpuBrand, onChanged: (v) => setState(() => _filterGpuBrand = v.isEmpty ? null : v)),
          _FilterInput(label: 'RAM Type', initialValue: _filterRamType, onChanged: (v) => setState(() => _filterRamType = v.isEmpty ? null : v)),
          _FilterInput(label: 'Storage Type', initialValue: _filterStorageType, onChanged: (v) => setState(() => _filterStorageType = v.isEmpty ? null : v)),
          _FilterInput(label: 'Resolution', initialValue: _filterResolution, onChanged: (v) => setState(() => _filterResolution = v.isEmpty ? null : v)),
          _FilterInput(label: 'Panel Type', initialValue: _filterPanelType, onChanged: (v) => setState(() => _filterPanelType = v.isEmpty ? null : v)),

          Divider(color: Theme.of(context).dividerColor, indent: 16, endIndent: 16),
          Padding(padding: const EdgeInsets.only(left: 20, top: 8), child: Align(alignment: Alignment.centerLeft,
            child: Text('Range Filters', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600)))),

          _FilterInput(label: 'Min RAM (GB)', initialValue: _filterMinRamGb?.toString(), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _filterMinRamGb = v.isEmpty ? null : int.tryParse(v))),
          _FilterInput(label: 'Max RAM (GB)', initialValue: _filterMaxRamGb?.toString(), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _filterMaxRamGb = v.isEmpty ? null : int.tryParse(v))),
          _FilterInput(label: 'Min Storage (GB)', initialValue: _filterMinStorageGb?.toString(), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _filterMinStorageGb = v.isEmpty ? null : int.tryParse(v))),
          _FilterInput(label: 'Min VRAM (GB)', initialValue: _filterMinVramGb?.toString(), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _filterMinVramGb = v.isEmpty ? null : int.tryParse(v))),
          _FilterInput(label: 'Min Screen (Inch)', initialValue: _filterMinDisplayInch?.toString(), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => setState(() => _filterMinDisplayInch = v.isEmpty ? null : double.tryParse(v))),
          _FilterInput(label: 'Max Screen (Inch)', initialValue: _filterMaxDisplayInch?.toString(), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => setState(() => _filterMaxDisplayInch = v.isEmpty ? null : double.tryParse(v))),
          _FilterInput(label: 'Min Refresh Rate (Hz)', initialValue: _filterMinRefreshRateHz?.toString(), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _filterMinRefreshRateHz = v.isEmpty ? null : int.tryParse(v))),
          _FilterInput(label: 'Max Weight (kg)', initialValue: _filterMaxWeightKg?.toString(), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => setState(() => _filterMaxWeightKg = v.isEmpty ? null : double.tryParse(v))),
          _FilterInput(label: 'Min Battery (Wh)', initialValue: _filterMinBatteryWh?.toString(), keyboardType: TextInputType.number, onChanged: (v) => setState(() => _filterMinBatteryWh = v.isEmpty ? null : int.tryParse(v))),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ),
          const SizedBox(height: 24),
        ]))),
      ]),
    );
  }

  Widget _dropdownFilter(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1D27) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
        ),
        items: [
          DropdownMenuItem(value: null, child: Text('All', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _FilterInput extends StatefulWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const _FilterInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_FilterInput> createState() => _FilterInputState();
}

class _FilterInputState extends State<_FilterInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant _FilterInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == null && _ctrl.text.isNotEmpty) {
      _ctrl.clear();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: _ctrl,
        keyboardType: widget.keyboardType,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class _HoverLaptopCard extends StatefulWidget {
  final Laptop laptop;
  final bool isFavorite;
  final VoidCallback onTap;
  const _HoverLaptopCard({required this.laptop, required this.isFavorite, required this.onTap});
  @override
  State<_HoverLaptopCard> createState() => _HoverLaptopCardState();
}

class _HoverLaptopCardState extends State<_HoverLaptopCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final l = widget.laptop;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AppTheme.glassContainer(
          context,
          isHovered: _hov,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(7)),
                child: Text(l.brand, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              if (widget.isFavorite) Icon(Icons.favorite, color: Theme.of(context).colorScheme.error, size: 20),
            ]),
            const SizedBox(height: 14),
            Text(l.series, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 21, height: 1.2),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 14),
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text('${l.cpuBrand} ${l.cpuSeries} ${l.cpuModelName}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text('${l.gpuModelName}${l.gpuVramGb != null ? ' ${l.gpuVramGb}GB' : ''}${l.gpuVramType != null ? ' ${l.gpuVramType}' : ''}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14), overflow: TextOverflow.ellipsis)),
            ]),
            const Spacer(),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _p(context, '${l.ramCapacityGb}GB RAM'),
              _p(context, '${l.storageCapacityGb}GB SSD'),
              _p(context, l.displayPanelType),
              _p(context, '${l.displayRefreshRateHz}Hz'),
              if (l.weightKg != null) _p(context, '${l.weightKg}kg'),
              _p(context, '${l.batteryWh}Wh'),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _p(BuildContext context, String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(6)),
    child: Text(t, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
  );
}
