import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../services/gemini_service.dart';

class PlantIdentificationPage extends StatefulWidget {
  const PlantIdentificationPage({super.key});

  @override
  State<PlantIdentificationPage> createState() => _PlantIdentificationPageState();
}

class _PlantIdentificationPageState extends State<PlantIdentificationPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  IdentifiedPlant? _result;
  String? _error;
  bool _isArabic = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _result = null;
          _error = null;
        });
        await _identifyPlant();
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
      });
    }
  }

  Future<void> _identifyPlant() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await GeminiService.instance.identifyPlant(
        _selectedImage!,
        inArabic: _isArabic,
      );

      if (response.success && response.plant != null) {
        setState(() {
          _result = response.plant;
        });
      } else {
        setState(() {
          _error = response.errorMessage ?? 'Could not identify the plant';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleLanguage() async {
    setState(() {
      _isArabic = !_isArabic;
    });
    // Re-identify with the new language if we have an image
    if (_selectedImage != null && _result != null) {
      await _identifyPlant();
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isArabic ? 'اختر مصدر الصورة' : 'Select Image Source',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: _isArabic ? 'الكاميرا' : 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: _isArabic ? 'المعرض' : 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_isArabic ? 'تعريف النبات' : 'Plant Identification'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
          actions: [
            // Language Toggle Button
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _toggleLanguage,
                icon: Icon(
                  Icons.translate_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                label: Text(
                  _isArabic ? 'EN' : 'عربي',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              GlassCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isArabic ? 'مُعرِّف النباتات بالذكاء الاصطناعي' : 'AI Plant Identifier',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isArabic 
                          ? 'التقط صورة أو ارفع صورة لأي نبات للتعرف عليه فوراً باستخدام الذكاء الاصطناعي'
                          : 'Take a photo or upload an image of any plant to identify it instantly using AI',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Image Preview / Upload Area
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: GlassCard(
                  child: _selectedImage != null
                      ? Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(_isArabic ? 'اختر صورة أخرى' : 'Choose Different Image'),
                            ),
                          ],
                        )
                      : Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 64,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isArabic ? 'اضغط لإضافة صورة نبات' : 'Tap to add a plant image',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isArabic ? 'الكاميرا أو المعرض' : 'Camera or Gallery',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Loading State
              if (_isLoading)
                GlassCard(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        _isArabic ? 'جاري تحليل النبات...' : 'Analyzing plant...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isArabic ? 'الذكاء الاصطناعي يتعرف على نباتك' : 'AI is identifying your plant',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

              // Error State
              if (_error != null)
                GlassCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isArabic ? 'فشل التعرف' : 'Identification Failed',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(_isArabic ? 'حاول مرة أخرى' : 'Try Again'),
                      ),
                    ],
                  ),
                ),

              // Result Display
              if (_result != null) ...[
                _buildResultCard(),
                const SizedBox(height: 16),
                _buildCareInstructionsCard(),
                const SizedBox(height: 16),
                _buildCharacteristicsCard(),
                if (_result!.funFacts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildFunFactsCard(),
                ],
                if (_result!.warnings != null) ...[
                  const SizedBox(height: 16),
                  _buildWarningsCard(),
                ],
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic ? 'تم التعرف على النبات!' : 'Plant Identified!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                    Text(
                      _result!.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            _isArabic ? 'الاسم العلمي' : 'Scientific Name',
            _result!.scientificName,
            Icons.science_rounded,
          ),
          _buildInfoRow(
            _isArabic ? 'العائلة' : 'Family',
            _result!.family,
            Icons.family_restroom_rounded,
          ),
          _buildInfoRow(
            _isArabic ? 'الثقة' : 'Confidence',
            '${(_result!.confidence * 100).toStringAsFixed(0)}%',
            Icons.psychology_rounded,
          ),
          const Divider(height: 24),
          Text(
            _result!.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.secondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareInstructionsCard() {
    final care = _result!.careInstructions;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                _isArabic ? 'تعليمات العناية' : 'Care Instructions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCareItem(
            Icons.water_drop_rounded,
            _isArabic ? 'الري' : 'Watering',
            care.watering,
            Colors.blue,
          ),
          _buildCareItem(
            Icons.wb_sunny_rounded,
            _isArabic ? 'الإضاءة' : 'Sunlight',
            care.sunlight,
            Colors.orange,
          ),
          _buildCareItem(
            Icons.water_rounded,
            _isArabic ? 'الرطوبة' : 'Humidity',
            care.humidity,
            Colors.cyan,
          ),
          _buildCareItem(
            Icons.thermostat_rounded,
            _isArabic ? 'الحرارة' : 'Temperature',
            care.temperature,
            Colors.red,
          ),
          _buildCareItem(
            Icons.grass_rounded,
            _isArabic ? 'التربة' : 'Soil',
            care.soil,
            Colors.brown,
          ),
          _buildCareItem(
            Icons.science_rounded,
            _isArabic ? 'التسميد' : 'Fertilizer',
            care.fertilizer,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem(IconData icon, String title, String value, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsCard() {
    final chars = _result!.characteristics;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                _isArabic ? 'الخصائص' : 'Characteristics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Use Column instead of Wrap to prevent overflow
          if (chars.type.isNotEmpty)
            _buildCharacteristicRow(
              Icons.category_rounded,
              _isArabic ? 'النوع' : 'Type',
              chars.type,
            ),
          if (chars.leafShape.isNotEmpty)
            _buildCharacteristicRow(
              Icons.eco_rounded,
              _isArabic ? 'الأوراق' : 'Leaves',
              chars.leafShape,
            ),
          if (chars.flowerColor.isNotEmpty)
            _buildCharacteristicRow(
              Icons.local_florist_rounded,
              _isArabic ? 'الأزهار' : 'Flowers',
              chars.flowerColor,
            ),
          if (chars.height.isNotEmpty)
            _buildCharacteristicRow(
              Icons.height_rounded,
              _isArabic ? 'الارتفاع' : 'Height',
              chars.height,
            ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunFactsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                _isArabic ? 'حقائق ممتعة' : 'Fun Facts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_result!.funFacts.map((fact) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                    Expanded(
                      child: Text(
                        fact,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))),
        ],
      ),
    );
  }

  Widget _buildWarningsCard() {
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.warning.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isArabic ? 'تحذير' : 'Warning',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _result!.warnings!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
