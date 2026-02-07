import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../services/supabase_service.dart';
import 'widgets/add_plant_dialog.dart';
import 'widgets/growth_chart.dart';

class MyPlantsPage extends StatefulWidget {
  const MyPlantsPage({super.key});

  @override
  State<MyPlantsPage> createState() => _MyPlantsPageState();
}

class _MyPlantsPageState extends State<MyPlantsPage> {
  List<PlantData> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    try {
      final plantsData = await SupabaseService.instance.getUserPlants();
      setState(() {
        _plants = plantsData.map((data) => PlantData.fromMap(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading plants: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading plants: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addPlant(PlantData plant) {
    setState(() {
      _plants.add(plant);
    });
    _loadPlants(); // Reload to get from database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final plant = await showDialog<PlantData>(
                context: context,
                builder: (context) => const AddPlantDialog(),
              );
              if (plant != null) {
                _addPlant(plant);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPlants,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._plants.map((plant) => _buildPlantCard(plant)),
                      const SizedBox(height: 16),
                      if (_plants.isNotEmpty) GrowthChart(plants: _plants),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_florist_outlined,
            size: 100,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'No plants yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first plant to start tracking',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final plant = await showDialog<PlantData>(
                context: context,
                builder: (context) => const AddPlantDialog(),
              );
              if (plant != null) {
                _addPlant(plant);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Plant'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(PlantData plant) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: plant.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.local_florist,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.local_florist,
                        size: 40,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.scientificName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip('Health', plant.health, _getHealthColor(plant.health)),
                        const SizedBox(width: 8),
                        _buildStatusChip('Growth', '${plant.growthPercentage}%', AppColors.success),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.secondary.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.calendar_today, 'Added', plant.dateAdded),
              _buildInfoItem(Icons.water_drop, 'Next Water', plant.nextWatering),
              _buildInfoItem(Icons.health_and_safety, 'Status', plant.health),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Color _getHealthColor(String health) {
    switch (health.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return AppColors.info;
      case 'fair':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}

class PlantData {
  final String name;
  final String scientificName;
  final String health;
  final int growthPercentage;
  final String dateAdded;
  final String nextWatering;
  final String? imageUrl;
  final String? id;

  PlantData({
    required this.name,
    required this.scientificName,
    required this.health,
    required this.growthPercentage,
    required this.dateAdded,
    required this.nextWatering,
    this.imageUrl,
    this.id,
  });

  factory PlantData.fromMap(Map<String, dynamic> map) {
    return PlantData(
      id: map['id'] as String?,
      name: map['name'] as String,
      scientificName: map['scientific_name'] as String? ?? '',
      health: map['health_status'] as String? ?? 'Good',
      growthPercentage: (map['growth_percentage'] as num?)?.toInt() ?? 50,
      dateAdded: map['date_added'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
      nextWatering: map['next_watering_date'] as String? ?? 'In 3 days',
      imageUrl: map['image_url'] as String?,
    );
  }
}

