import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final Laptop laptop;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const DetailScreen({
    super.key,
    required this.laptop,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() => isFavorite = !isFavorite);
    widget.onToggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.buildBackground(
      context,
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Technical Specifications'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Basic Specifications',
              icon: Icons.info_outline,
              items: {
                'RAM': '${widget.laptop.ramCapacityGb} GB ${widget.laptop.ramType} ${widget.laptop.ramSpeedMhz}MHz',
                'Storage': '${widget.laptop.storageCapacityGb} GB ${widget.laptop.storageType}',
                'Wi-Fi': widget.laptop.wifiVersion ?? '-',
                'Bluetooth': widget.laptop.bluetoothVersion ?? '-',
              },
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Processor Specifications',
              icon: Icons.memory,
              items: {
                'Processor Model': '${widget.laptop.cpuBrand} ${widget.laptop.cpuSeries} ${widget.laptop.cpuModelName}',
                'Cores / Threads': '${widget.laptop.cpuCoreCount} Cores / ${widget.laptop.cpuThreadCount} Threads',
                'Frequency': '${widget.laptop.cpuBaseClockGhz} GHz${widget.laptop.cpuBoostClockGhz != null ? ' (Max: ${widget.laptop.cpuBoostClockGhz} GHz)' : ''}',
                'Cache': '${widget.laptop.cpuCacheMb} MB',
              },
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Graphics Card',
              icon: Icons.videogame_asset,
              items: {
                'GPU Model': '${widget.laptop.gpuBrand} ${widget.laptop.gpuModelName}',
                if (widget.laptop.gpuVramGb != null)
                  'Memory (VRAM)': '${widget.laptop.gpuVramGb} GB${widget.laptop.gpuVramType != null ? ' ${widget.laptop.gpuVramType}' : ''}',
                if (widget.laptop.gpuMemoryBusBit != null)
                  'Memory Interface': '${widget.laptop.gpuMemoryBusBit}-bit',
                if (widget.laptop.gpuTdpWatt != null)
                  'TDP': '${widget.laptop.gpuTdpWatt} W',
              },
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Display Details',
              icon: Icons.monitor,
              items: {
                'Size': '${widget.laptop.displaySizeInch} Inch',
                'Resolution': widget.laptop.displayResolution,
                'Refresh Rate': '${widget.laptop.displayRefreshRateHz} Hz',
                'Panel Type': widget.laptop.displayPanelType,
                if (widget.laptop.displayBrightnessNits != null)
                  'Brightness': '${widget.laptop.displayBrightnessNits} Nits',
              },
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Physical & Other Specifications',
              icon: Icons.straighten,
              items: {
                'Weight': widget.laptop.weightKg != null ? '${widget.laptop.weightKg} kg' : '-',
                'Thickness': '${widget.laptop.thicknessMm} mm',
                'Battery': '${widget.laptop.batteryWh} Wh',
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeaderCard(BuildContext context) {
    return AppTheme.glassContainer(
      context,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Hero(
            tag: 'laptop_${widget.laptop.id}',
            child: Icon(
              Icons.laptop_mac,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${widget.laptop.brand} ${widget.laptop.series}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required IconData icon, required Map<String, String> items}) {
    return AppTheme.glassContainer(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: items.entries.map((entry) => _buildListTile(context, entry.key, entry.value)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            )),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
