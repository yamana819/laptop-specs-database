import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../models/cpu.dart';
import '../models/gpu.dart';
import '../models/display.dart' as d;
import '../models/paged_response.dart';
import '../services/laptop_service.dart';
import '../services/cpu_service.dart';
import '../services/gpu_service.dart';
import '../services/display_service.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _laptopService = LaptopService();
  final _cpuService = CpuService();
  final _gpuService = GpuService();
  final _displayService = DisplayService();

  List<Laptop> _laptops = [];
  List<Cpu> _cpus = [];
  List<Gpu> _gpus = [];
  List<d.Display> _displays = [];

  bool _loadingLaptops = true;
  bool _loadingCpus = true;
  bool _loadingGpus = true;
  bool _loadingDisplays = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadLaptops(),
      _loadCpus(),
      _loadGpus(),
      _loadDisplays(),
    ]);
  }

  Future<void> _loadLaptops() async {
    setState(() => _loadingLaptops = true);
    try {
      final paged = await _laptopService.getLaptops(size: 100);
      setState(() {
        _laptops = paged.content;
        _loadingLaptops = false;
      });
    } catch (e) {
      setState(() => _loadingLaptops = false);
      _showError('Error loading laptops: $e');
    }
  }

  Future<void> _loadCpus() async {
    setState(() => _loadingCpus = true);
    try {
      final list = await _cpuService.getAllCpus();
      setState(() {
        _cpus = list;
        _loadingCpus = false;
      });
    } catch (e) {
      setState(() => _loadingCpus = false);
      _showError('Error loading processors: $e');
    }
  }

  Future<void> _loadGpus() async {
    setState(() => _loadingGpus = true);
    try {
      final list = await _gpuService.getAllGpus();
      setState(() {
        _gpus = list;
        _loadingGpus = false;
      });
    } catch (e) {
      setState(() => _loadingGpus = false);
      _showError('Error loading graphics cards: $e');
    }
  }

  Future<void> _loadDisplays() async {
    setState(() => _loadingDisplays = true);
    try {
      final list = await _displayService.getAllDisplays();
      setState(() {
        _displays = list;
        _loadingDisplays = false;
      });
    } catch (e) {
      setState(() => _loadingDisplays = false);
      _showError('Error loading displays: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }

  Future<bool> _confirmDelete(String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Confirm Deletion', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          '"$itemName" will be deleted. Are you sure?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.buildBackground(
      context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Admin Panel',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Laptops'),
            Tab(text: 'Processors'),
            Tab(text: 'Graphics Cards'),
            Tab(text: 'Displays'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LaptopTab(
            laptops: _laptops,
            cpus: _cpus,
            gpus: _gpus,
            displays: _displays,
            loading: _loadingLaptops,
            laptopService: _laptopService,
            onRefresh: _loadLaptops,
            showSuccess: _showSuccess,
            showError: _showError,
            confirmDelete: _confirmDelete,
          ),
          _CpuTab(
            cpus: _cpus,
            loading: _loadingCpus,
            cpuService: _cpuService,
            onRefresh: () async {
              await _loadCpus();
            },
            showSuccess: _showSuccess,
            showError: _showError,
            confirmDelete: _confirmDelete,
          ),
          _GpuTab(
            gpus: _gpus,
            loading: _loadingGpus,
            gpuService: _gpuService,
            onRefresh: () async {
              await _loadGpus();
            },
            showSuccess: _showSuccess,
            showError: _showError,
            confirmDelete: _confirmDelete,
          ),
          _DisplayTab(
            displays: _displays,
            loading: _loadingDisplays,
            displayService: _displayService,
            onRefresh: () async {
              await _loadDisplays();
            },
            showSuccess: _showSuccess,
            showError: _showError,
            confirmDelete: _confirmDelete,
          ),
        ],
      ),
    ));
  }
}

InputDecoration _inputDecoration(BuildContext context, String label, {bool required = false}) {
  return InputDecoration(
    labelText: required ? '$label *' : label,
    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    isDense: true,
  );
}

Widget _sectionTitle(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _loadingCenter(BuildContext context) {
  return Center(
    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
  );
}

class _LaptopTab extends StatefulWidget {
  final List<Laptop> laptops;
  final List<Cpu> cpus;
  final List<Gpu> gpus;
  final List<d.Display> displays;
  final bool loading;
  final LaptopService laptopService;
  final Future<void> Function() onRefresh;
  final void Function(String) showSuccess;
  final void Function(String) showError;
  final Future<bool> Function(String) confirmDelete;

  const _LaptopTab({
    required this.laptops,
    required this.cpus,
    required this.gpus,
    required this.displays,
    required this.loading,
    required this.laptopService,
    required this.onRefresh,
    required this.showSuccess,
    required this.showError,
    required this.confirmDelete,
  });

  @override
  State<_LaptopTab> createState() => _LaptopTabState();
}

class _LaptopTabState extends State<_LaptopTab> {
  final _formKey = GlobalKey<FormState>();

  final _brandCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _ramCapacityCtrl = TextEditingController();
  final _ramSpeedCtrl = TextEditingController();
  final _ramTypeCtrl = TextEditingController();
  final _storageCapacityCtrl = TextEditingController();
  final _storageTypeCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _thicknessCtrl = TextEditingController();
  final _batteryCtrl = TextEditingController();
  final _wifiCtrl = TextEditingController();
  final _bluetoothCtrl = TextEditingController();

  int? _selectedCpuId;
  int? _selectedGpuId;
  int? _selectedDisplayId;

  bool _saving = false;
  int? _editingId; 

  @override
  void dispose() {
    _brandCtrl.dispose();
    _seriesCtrl.dispose();
    _ramCapacityCtrl.dispose();
    _ramSpeedCtrl.dispose();
    _ramTypeCtrl.dispose();
    _storageCapacityCtrl.dispose();
    _storageTypeCtrl.dispose();
    _weightCtrl.dispose();
    _thicknessCtrl.dispose();
    _batteryCtrl.dispose();
    _wifiCtrl.dispose();
    _bluetoothCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _brandCtrl.clear();
    _seriesCtrl.clear();
    _ramCapacityCtrl.clear();
    _ramSpeedCtrl.clear();
    _ramTypeCtrl.clear();
    _storageCapacityCtrl.clear();
    _storageTypeCtrl.clear();
    _weightCtrl.clear();
    _thicknessCtrl.clear();
    _batteryCtrl.clear();
    _wifiCtrl.clear();
    _bluetoothCtrl.clear();
    setState(() {
      _selectedCpuId = null;
      _selectedGpuId = null;
      _selectedDisplayId = null;
      _editingId = null;
    });
  }

  void _populateForEdit(Laptop l) {
    _brandCtrl.text = l.brand;
    _seriesCtrl.text = l.series;
    _ramCapacityCtrl.text = l.ramCapacityGb.toString();
    _ramSpeedCtrl.text = l.ramSpeedMhz.toString();
    _ramTypeCtrl.text = l.ramType;
    _storageCapacityCtrl.text = l.storageCapacityGb.toString();
    _storageTypeCtrl.text = l.storageType;
    _weightCtrl.text = l.weightKg?.toString() ?? '';
    _thicknessCtrl.text = l.thicknessMm.toString();
    _batteryCtrl.text = l.batteryWh.toString();
    _wifiCtrl.text = l.wifiVersion ?? '';
    _bluetoothCtrl.text = l.bluetoothVersion ?? '';

    final matchedCpu = widget.cpus.cast<Cpu?>().firstWhere(
      (c) =>
          c!.brand == l.cpuBrand &&
          c.series == l.cpuSeries &&
          c.modelName == l.cpuModelName,
      orElse: () => null,
    );
    final matchedGpu = widget.gpus.cast<Gpu?>().firstWhere(
      (g) => g!.brand == l.gpuBrand && g.modelName == l.gpuModelName,
      orElse: () => null,
    );
    final matchedDisplay = widget.displays.cast<d.Display?>().firstWhere(
      (di) =>
          di!.sizeInch == l.displaySizeInch &&
          di.resolution == l.displayResolution &&
          di.refreshRateHz == l.displayRefreshRateHz &&
          di.panelType == l.displayPanelType,
      orElse: () => null,
    );

    setState(() {
      _editingId = l.id;
      _selectedCpuId = matchedCpu?.id;
      _selectedGpuId = matchedGpu?.id;
      _selectedDisplayId = matchedDisplay?.id;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCpuId == null ||
        _selectedGpuId == null ||
        _selectedDisplayId == null) {
      widget.showError('Please select CPU, GPU and Display.');
      return;
    }

    setState(() => _saving = true);
    try {
      final request = LaptopRequest(
        brand: _brandCtrl.text.trim(),
        series: _seriesCtrl.text.trim(),
        cpuId: _selectedCpuId!,
        gpuId: _selectedGpuId!,
        displayId: _selectedDisplayId!,
        ramCapacityGb: int.parse(_ramCapacityCtrl.text.trim()),
        ramSpeedMhz: int.parse(_ramSpeedCtrl.text.trim()),
        ramType: _ramTypeCtrl.text.trim(),
        storageCapacityGb: int.parse(_storageCapacityCtrl.text.trim()),
        storageType: _storageTypeCtrl.text.trim(),
        weightKg: _weightCtrl.text.trim().isEmpty
            ? null
            : double.parse(_weightCtrl.text.trim()),
        thicknessMm: double.parse(_thicknessCtrl.text.trim()),
        batteryWh: int.parse(_batteryCtrl.text.trim()),
        wifiVersion:
            _wifiCtrl.text.trim().isEmpty ? null : _wifiCtrl.text.trim(),
        bluetoothVersion: _bluetoothCtrl.text.trim().isEmpty
            ? null
            : _bluetoothCtrl.text.trim(),
      );

      if (_editingId != null) {
        await widget.laptopService.updateLaptop(_editingId!, request);
        widget.showSuccess('Laptop updated.');
      } else {
        await widget.laptopService.createLaptop(request);
        widget.showSuccess('Laptop added.');
      }
      _clearForm();
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Operation failed: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete(Laptop l) async {
    final confirm =
        await widget.confirmDelete('${l.brand} ${l.series}');
    if (!confirm) return;
    try {
      await widget.laptopService.deleteLaptop(l.id);
      widget.showSuccess('Laptop deleted.');
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Deletion failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppTheme.glassContainer(
            context,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _sectionTitle(context, 
                      _editingId != null ? 'Edit Laptop' : 'New Laptop'),
                  const SizedBox(height: 4),
                  _buildTextField(context, _brandCtrl, 'Brand', required: true),
                  const SizedBox(height: 10),
                  _buildTextField(context, _seriesCtrl, 'Series', required: true),
                  const SizedBox(height: 10),

                  _buildDropdown<Cpu>(
                    context: context,
                    label: 'Processor (CPU) *',
                    value: _selectedCpuId,
                    items: widget.cpus,
                    itemId: (c) => c.id,
                    itemLabel: (c) => c.displayLabel,
                    onChanged: (v) => setState(() => _selectedCpuId = v),
                  ),
                  const SizedBox(height: 10),

                  _buildDropdown<Gpu>(
                    context: context,
                    label: 'Graphics Card (GPU) *',
                    value: _selectedGpuId,
                    items: widget.gpus,
                    itemId: (g) => g.id,
                    itemLabel: (g) => g.displayLabel,
                    onChanged: (v) => setState(() => _selectedGpuId = v),
                  ),
                  const SizedBox(height: 10),

                  _buildDropdown<d.Display>(
                    context: context,
                    label: 'Display *',
                    value: _selectedDisplayId,
                    items: widget.displays,
                    itemId: (di) => di.id,
                    itemLabel: (di) => di.displayLabel,
                    onChanged: (v) => setState(() => _selectedDisplayId = v),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(context, 
                          _ramCapacityCtrl,
                          'RAM (GB)',
                          required: true,
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(context, 
                          _ramSpeedCtrl,
                          'RAM Speed (MHz)',
                          required: true,
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(context, 
                          _ramTypeCtrl,
                          'RAM Type',
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(context, 
                          _storageCapacityCtrl,
                          'Storage (GB)',
                          required: true,
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(context, 
                          _storageTypeCtrl,
                          'Storage Type',
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(context, 
                          _weightCtrl,
                          'Weight (kg)',
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(context, 
                          _thicknessCtrl,
                          'Thickness (mm)',
                          required: true,
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(context, 
                          _batteryCtrl,
                          'Battery (Wh)',
                          required: true,
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(context, _wifiCtrl, 'WiFi Version'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:
                            _buildTextField(context, _bluetoothCtrl, 'Bluetooth Version'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _submit,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _editingId != null
                                      ? Icons.save
                                      : Icons.add,
                                ),
                          label: Text(
                              _editingId != null ? 'Update' : 'Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (_editingId != null) ...[
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: _clearForm,
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: widget.loading
              ? _loadingCenter(context)
              : widget.laptops.isEmpty
                  ? Center(
                      child: Text(
                        'No laptops yet.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.laptops.length,
                      itemBuilder: (ctx, i) {
                        final l = widget.laptops[i];
                        return AppTheme.glassContainer(
                          context,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              '${l.brand} ${l.series}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${l.cpuBrand} ${l.cpuModelName}  •  ${l.gpuBrand} ${l.gpuModelName}',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Theme.of(context).colorScheme.secondary, size: 20),
                                  tooltip: 'Edit',
                                  onPressed: () => _populateForEdit(l),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Theme.of(context).colorScheme.error, size: 20),
                                  tooltip: 'Delete',
                                  onPressed: () => _delete(l),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      keyboardType: keyboard,
      decoration: _inputDecoration(context, label, required: required),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null
          : null,
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required int? value,
    required List<T> items,
    required int Function(T) itemId,
    required String Function(T) itemLabel,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: _inputDecoration(context, label),
      dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1D27) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: itemId(item),
              child: Text(
                itemLabel(item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required field' : null,
    );
  }
}

class _CpuTab extends StatefulWidget {
  final List<Cpu> cpus;
  final bool loading;
  final CpuService cpuService;
  final Future<void> Function() onRefresh;
  final void Function(String) showSuccess;
  final void Function(String) showError;
  final Future<bool> Function(String) confirmDelete;

  const _CpuTab({
    required this.cpus,
    required this.loading,
    required this.cpuService,
    required this.onRefresh,
    required this.showSuccess,
    required this.showError,
    required this.confirmDelete,
  });

  @override
  State<_CpuTab> createState() => _CpuTabState();
}

class _CpuTabState extends State<_CpuTab> {
  final _formKey = GlobalKey<FormState>();

  final _brandCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _modelNameCtrl = TextEditingController();
  final _baseClockCtrl = TextEditingController();
  final _boostClockCtrl = TextEditingController();
  final _coreCountCtrl = TextEditingController();
  final _threadCountCtrl = TextEditingController();
  final _cacheMbCtrl = TextEditingController();

  bool _saving = false;
  int? _editingId;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _seriesCtrl.dispose();
    _modelNameCtrl.dispose();
    _baseClockCtrl.dispose();
    _boostClockCtrl.dispose();
    _coreCountCtrl.dispose();
    _threadCountCtrl.dispose();
    _cacheMbCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _brandCtrl.clear();
    _seriesCtrl.clear();
    _modelNameCtrl.clear();
    _baseClockCtrl.clear();
    _boostClockCtrl.clear();
    _coreCountCtrl.clear();
    _threadCountCtrl.clear();
    _cacheMbCtrl.clear();
    setState(() => _editingId = null);
  }

  void _populateForEdit(Cpu c) {
    _brandCtrl.text = c.brand;
    _seriesCtrl.text = c.series;
    _modelNameCtrl.text = c.modelName;
    _baseClockCtrl.text = c.baseClockGhz.toString();
    _boostClockCtrl.text = c.boostClockGhz?.toString() ?? '';
    _coreCountCtrl.text = c.coreCount.toString();
    _threadCountCtrl.text = c.threadCount.toString();
    _cacheMbCtrl.text = c.cacheMb.toString();
    setState(() => _editingId = c.id);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final cpu = Cpu(
        id: _editingId ?? 0,
        brand: _brandCtrl.text.trim(),
        series: _seriesCtrl.text.trim(),
        modelName: _modelNameCtrl.text.trim(),
        baseClockGhz: double.parse(_baseClockCtrl.text.trim()),
        boostClockGhz: _boostClockCtrl.text.trim().isEmpty
            ? null
            : double.parse(_boostClockCtrl.text.trim()),
        coreCount: int.parse(_coreCountCtrl.text.trim()),
        threadCount: int.parse(_threadCountCtrl.text.trim()),
        cacheMb: int.parse(_cacheMbCtrl.text.trim()),
      );

      if (_editingId != null) {
        await widget.cpuService.updateCpu(_editingId!, cpu);
        widget.showSuccess('Processor updated.');
      } else {
        await widget.cpuService.createCpu(cpu);
        widget.showSuccess('Processor added.');
      }
      _clearForm();
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Operation failed: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete(Cpu c) async {
    final confirm = await widget.confirmDelete(c.displayLabel);
    if (!confirm) return;
    try {
      await widget.cpuService.deleteCpu(c.id);
      widget.showSuccess('Processor deleted.');
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Deletion failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _sectionTitle(context, 
                      _editingId != null ? 'Edit Processor' : 'New Processor'),
                  const SizedBox(height: 4),
                  _field(context, _brandCtrl, 'Brand', req: true),
                  const SizedBox(height: 10),
                  _field(context, _seriesCtrl, 'Series', req: true),
                  const SizedBox(height: 10),
                  _field(context, _modelNameCtrl, 'Model Name', req: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _field(context, _baseClockCtrl, 'Base Clock (GHz)',
                              req: true, num: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _field(context, _boostClockCtrl, 'Boost Clock (GHz)',
                              num: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _field(context, _coreCountCtrl, 'Cores',
                              req: true, num: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _field(context, _threadCountCtrl, 'Threads',
                              req: true, num: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _field(context, _cacheMbCtrl, 'Cache (MB)',
                              req: true, num: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _actionButtons(context),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: widget.loading
              ? _loadingCenter(context)
              : widget.cpus.isEmpty
                  ? Center(
                      child: Text('No processors yet.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.cpus.length,
                      itemBuilder: (ctx, i) {
                        final c = widget.cpus[i];
                        return _itemCard(context, 
                          title: c.displayLabel,
                          subtitle:
                              '${c.coreCount}C/${c.threadCount}T  •  ${c.baseClockGhz} GHz  •  ${c.cacheMb} MB',
                          onEdit: () => _populateForEdit(c),
                          onDelete: () => _delete(c),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _field(BuildContext context, TextEditingController ctrl, String label,
      {bool req = false, bool num = false}) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(context, label, required: req),
      validator:
          req ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null : null,
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(_editingId != null ? Icons.save : Icons.add),
            label: Text(_editingId != null ? 'Update' : 'Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        if (_editingId != null) ...[
          const SizedBox(width: 10),
          TextButton(
            onPressed: _clearForm,
            child:
                Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ],
    );
  }

  Widget _itemCard(BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return AppTheme.glassContainer(
      context,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary, size: 20),
                tooltip: 'Edit',
                onPressed: onEdit),
            IconButton(
                icon:
                    Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 20),
                tooltip: 'Delete',
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _GpuTab extends StatefulWidget {
  final List<Gpu> gpus;
  final bool loading;
  final GpuService gpuService;
  final Future<void> Function() onRefresh;
  final void Function(String) showSuccess;
  final void Function(String) showError;
  final Future<bool> Function(String) confirmDelete;

  const _GpuTab({
    required this.gpus,
    required this.loading,
    required this.gpuService,
    required this.onRefresh,
    required this.showSuccess,
    required this.showError,
    required this.confirmDelete,
  });

  @override
  State<_GpuTab> createState() => _GpuTabState();
}

class _GpuTabState extends State<_GpuTab> {
  final _formKey = GlobalKey<FormState>();

  final _brandCtrl = TextEditingController();
  final _modelNameCtrl = TextEditingController();
  final _tdpCtrl = TextEditingController();
  final _vramGbCtrl = TextEditingController();
  final _vramTypeCtrl = TextEditingController();
  final _memBusCtrl = TextEditingController();

  bool _saving = false;
  int? _editingId;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelNameCtrl.dispose();
    _tdpCtrl.dispose();
    _vramGbCtrl.dispose();
    _vramTypeCtrl.dispose();
    _memBusCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _brandCtrl.clear();
    _modelNameCtrl.clear();
    _tdpCtrl.clear();
    _vramGbCtrl.clear();
    _vramTypeCtrl.clear();
    _memBusCtrl.clear();
    setState(() => _editingId = null);
  }

  void _populateForEdit(Gpu g) {
    _brandCtrl.text = g.brand;
    _modelNameCtrl.text = g.modelName;
    _tdpCtrl.text = g.tdpWatt?.toString() ?? '';
    _vramGbCtrl.text = g.vramGb?.toString() ?? '';
    _vramTypeCtrl.text = g.vramType ?? '';
    _memBusCtrl.text = g.memoryBusBit?.toString() ?? '';
    setState(() => _editingId = g.id);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final gpu = Gpu(
        id: _editingId ?? 0,
        brand: _brandCtrl.text.trim(),
        modelName: _modelNameCtrl.text.trim(),
        tdpWatt:
            _tdpCtrl.text.trim().isEmpty ? null : int.parse(_tdpCtrl.text.trim()),
        vramGb: _vramGbCtrl.text.trim().isEmpty
            ? null
            : int.parse(_vramGbCtrl.text.trim()),
        vramType:
            _vramTypeCtrl.text.trim().isEmpty ? null : _vramTypeCtrl.text.trim(),
        memoryBusBit: _memBusCtrl.text.trim().isEmpty
            ? null
            : int.parse(_memBusCtrl.text.trim()),
      );

      if (_editingId != null) {
        await widget.gpuService.updateGpu(_editingId!, gpu);
        widget.showSuccess('Graphics Card updated.');
      } else {
        await widget.gpuService.createGpu(gpu);
        widget.showSuccess('Graphics Card added.');
      }
      _clearForm();
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Operation failed: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete(Gpu g) async {
    final confirm = await widget.confirmDelete(g.displayLabel);
    if (!confirm) return;
    try {
      await widget.gpuService.deleteGpu(g.id);
      widget.showSuccess('Graphics Card deleted.');
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Deletion failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _sectionTitle(context, _editingId != null
                      ? 'Edit Graphics Card'
                      : 'New Graphics Card'),
                  const SizedBox(height: 4),
                  _field(context, _brandCtrl, 'Brand', req: true),
                  const SizedBox(height: 10),
                  _field(context, _modelNameCtrl, 'Model Name', req: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _field(context, _tdpCtrl, 'TDP (Watt)', num: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _field(context, _vramGbCtrl, 'VRAM (GB)', num: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _field(context, _vramTypeCtrl, 'VRAM Type')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _field(context, _memBusCtrl, 'Memory Bus (bit)',
                              num: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _actionButtons(context),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: widget.loading
              ? _loadingCenter(context)
              : widget.gpus.isEmpty
                  ? Center(
                      child: Text('No graphics cards yet.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.gpus.length,
                      itemBuilder: (ctx, i) {
                        final g = widget.gpus[i];
                        final parts = <String>[];
                        if (g.vramGb != null) parts.add('${g.vramGb} GB');
                        if (g.vramType != null) parts.add(g.vramType!);
                        if (g.tdpWatt != null) parts.add('${g.tdpWatt}W');
                        return _itemCard(context, 
                          title: g.displayLabel,
                          subtitle:
                              parts.isEmpty ? '—' : parts.join('  •  '),
                          onEdit: () => _populateForEdit(g),
                          onDelete: () => _delete(g),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _field(BuildContext context, TextEditingController ctrl, String label,
      {bool req = false, bool num = false}) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(context, label, required: req),
      validator:
          req ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null : null,
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(_editingId != null ? Icons.save : Icons.add),
            label: Text(_editingId != null ? 'Update' : 'Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        if (_editingId != null) ...[
          const SizedBox(width: 10),
          TextButton(
            onPressed: _clearForm,
            child:
                Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ],
    );
  }

  Widget _itemCard(BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary, size: 20),
                tooltip: 'Edit',
                onPressed: onEdit),
            IconButton(
                icon:
                    Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 20),
                tooltip: 'Delete',
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _DisplayTab extends StatefulWidget {
  final List<d.Display> displays;
  final bool loading;
  final DisplayService displayService;
  final Future<void> Function() onRefresh;
  final void Function(String) showSuccess;
  final void Function(String) showError;
  final Future<bool> Function(String) confirmDelete;

  const _DisplayTab({
    required this.displays,
    required this.loading,
    required this.displayService,
    required this.onRefresh,
    required this.showSuccess,
    required this.showError,
    required this.confirmDelete,
  });

  @override
  State<_DisplayTab> createState() => _DisplayTabState();
}

class _DisplayTabState extends State<_DisplayTab> {
  final _formKey = GlobalKey<FormState>();

  final _sizeCtrl = TextEditingController();
  final _resolutionCtrl = TextEditingController();
  final _refreshCtrl = TextEditingController();
  final _panelCtrl = TextEditingController();
  final _brightnessCtrl = TextEditingController();

  bool _saving = false;
  int? _editingId;

  @override
  void dispose() {
    _sizeCtrl.dispose();
    _resolutionCtrl.dispose();
    _refreshCtrl.dispose();
    _panelCtrl.dispose();
    _brightnessCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _sizeCtrl.clear();
    _resolutionCtrl.clear();
    _refreshCtrl.clear();
    _panelCtrl.clear();
    _brightnessCtrl.clear();
    setState(() => _editingId = null);
  }

  void _populateForEdit(d.Display di) {
    _sizeCtrl.text = di.sizeInch.toString();
    _resolutionCtrl.text = di.resolution;
    _refreshCtrl.text = di.refreshRateHz.toString();
    _panelCtrl.text = di.panelType;
    _brightnessCtrl.text = di.brightnessNits?.toString() ?? '';
    setState(() => _editingId = di.id);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final display = d.Display(
        id: _editingId ?? 0,
        sizeInch: double.parse(_sizeCtrl.text.trim()),
        resolution: _resolutionCtrl.text.trim(),
        refreshRateHz: int.parse(_refreshCtrl.text.trim()),
        panelType: _panelCtrl.text.trim(),
        brightnessNits: _brightnessCtrl.text.trim().isEmpty
            ? null
            : int.parse(_brightnessCtrl.text.trim()),
      );

      if (_editingId != null) {
        await widget.displayService.updateDisplay(_editingId!, display);
        widget.showSuccess('Display updated.');
      } else {
        await widget.displayService.createDisplay(display);
        widget.showSuccess('Display added.');
      }
      _clearForm();
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Operation failed: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete(d.Display di) async {
    final confirm = await widget.confirmDelete(di.displayLabel);
    if (!confirm) return;
    try {
      await widget.displayService.deleteDisplay(di.id);
      widget.showSuccess('Display deleted.');
      await widget.onRefresh();
    } catch (e) {
      widget.showError('Deletion failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _sectionTitle(context, 
                      _editingId != null ? 'Edit Display' : 'New Display'),
                  const SizedBox(height: 4),
                  _field(context, _sizeCtrl, 'Size (inch)', req: true, num: true),
                  const SizedBox(height: 10),
                  _field(context, _resolutionCtrl, 'Resolution', req: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _field(context, _refreshCtrl, 'Refresh Rate (Hz)',
                              req: true, num: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _field(context, _panelCtrl, 'Panel Type', req: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _field(context, _brightnessCtrl, 'Brightness (nits)', num: true),
                  const SizedBox(height: 20),
                  _actionButtons(context),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: widget.loading
              ? _loadingCenter(context)
              : widget.displays.isEmpty
                  ? Center(
                      child: Text('No displays yet.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.displays.length,
                      itemBuilder: (ctx, i) {
                        final di = widget.displays[i];
                        final sub = <String>[
                          di.panelType,
                        ];
                        if (di.brightnessNits != null) {
                          sub.add('${di.brightnessNits} nits');
                        }
                        return _itemCard(context, 
                          title: di.displayLabel,
                          subtitle: sub.join('  •  '),
                          onEdit: () => _populateForEdit(di),
                          onDelete: () => _delete(di),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _field(BuildContext context, TextEditingController ctrl, String label,
      {bool req = false, bool num = false}) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(context, label, required: req),
      validator:
          req ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null : null,
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(_editingId != null ? Icons.save : Icons.add),
            label: Text(_editingId != null ? 'Update' : 'Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        if (_editingId != null) ...[
          const SizedBox(width: 10),
          TextButton(
            onPressed: _clearForm,
            child:
                Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ],
    );
  }

  Widget _itemCard(BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary, size: 20),
                tooltip: 'Edit',
                onPressed: onEdit),
            IconButton(
                icon:
                    Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 20),
                tooltip: 'Delete',
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
