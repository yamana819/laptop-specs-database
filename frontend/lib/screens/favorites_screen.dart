import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../services/laptop_service.dart';
import 'detail_screen.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  final Set<int> favoriteIds;
  final void Function(int id) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _laptopService = LaptopService();
  List<Laptop> _favoriteLaptops = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (widget.favoriteIds.isEmpty) {
      setState(() { _favoriteLaptops = []; _isLoading = false; });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final List<Laptop> laptops = [];
      for (final id in widget.favoriteIds) {
        try {
          final laptop = await _laptopService.getLaptopById(id);
          laptops.add(laptop);
        } catch (_) {
        }
      }
      setState(() { _favoriteLaptops = laptops; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = 'Failed to load favorites: $e'; _isLoading = false; });
    }
  }

  void _removeFavorite(int id) {
    widget.onToggleFavorite(id);
    setState(() {
      _favoriteLaptops.removeWhere((l) => l.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.buildBackground(
      context,
      child: Scaffold(
        appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : _errorMessage != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadFavorites, child: const Text('Retry')),
                ]))
              : _favoriteLaptops.isEmpty
                  ? Center(child: Text(
                      'No laptops added to favorites yet.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                    ))
                  : SafeArea(
                      child: CustomScrollView(slivers: [
                        SliverToBoxAdapter(child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Text('${_favoriteLaptops.length} favorite products',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                        )),
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
                                (ctx, i) => _buildCard(_favoriteLaptops[i]),
                                childCount: _favoriteLaptops.length,
                              ),
                            );
                          }),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ]),
                    ),
    ));
  }

  Widget _buildCard(Laptop l) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => DetailScreen(
            laptop: l,
            isFavorite: true,
            onToggleFavorite: () => _removeFavorite(l.id),
          ),
        )).then((_) => _loadFavorites());
      },
      child: AppTheme.glassContainer(
        context,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(7)),
              child: Text(l.brand, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(Icons.favorite, color: Theme.of(context).colorScheme.error, size: 20),
              onPressed: () => _removeFavorite(l.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
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
            _pill('${l.ramCapacityGb}GB RAM'),
            _pill('${l.storageCapacityGb}GB SSD'),
            _pill(l.displayPanelType),
            _pill('${l.displayRefreshRateHz}Hz'),
            if (l.weightKg != null) _pill('${l.weightKg}kg'),
            _pill('${l.batteryWh}Wh'),
          ]),
        ]),
      ),
    );
  }

  Widget _pill(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(6)),
      child: Text(t, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
