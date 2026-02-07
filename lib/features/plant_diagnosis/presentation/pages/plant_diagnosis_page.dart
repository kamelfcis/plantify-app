import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../services/gemini_service.dart';

class PlantDiagnosisPage extends StatefulWidget {
  const PlantDiagnosisPage({super.key});

  @override
  State<PlantDiagnosisPage> createState() => _PlantDiagnosisPageState();
}

class _PlantDiagnosisPageState extends State<PlantDiagnosisPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _symptomsController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  PlantDiagnosis? _result;
  String? _error;
  bool _isArabic = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

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
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
      });
    }
  }

  Future<void> _diagnosePlant() async {
    if (_selectedImage == null) {
      setState(() {
        _error = _isArabic ? 'الرجاء اختيار صورة أولاً' : 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await GeminiService.instance.diagnosePlant(
        _selectedImage!,
        symptoms: _symptomsController.text.isNotEmpty ? _symptomsController.text : null,
        inArabic: _isArabic,
      );

      if (response.success && response.diagnosis != null) {
        setState(() {
          _result = response.diagnosis;
        });
      } else {
        setState(() {
          _error = response.errorMessage ?? 'Could not diagnose the plant';
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
    // Re-diagnose with the new language if we have an image and result
    if (_selectedImage != null && _result != null) {
      await _diagnosePlant();
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

  Color _getHealthColor(String health) {
    switch (health.toLowerCase()) {
      case 'healthy':
        return AppColors.success;
      case 'mild issues':
        return Colors.orange;
      case 'moderate issues':
        return Colors.deepOrange;
      case 'severe issues':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.orange;
      case 'moderate':
        return Colors.deepOrange;
      case 'severe':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'no action needed':
        return AppColors.success;
      case 'monitor':
        return Colors.blue;
      case 'act soon':
        return Colors.orange;
      case 'immediate action required':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'no action needed':
        return Icons.check_circle_rounded;
      case 'monitor':
        return Icons.visibility_rounded;
      case 'act soon':
        return Icons.schedule_rounded;
      case 'immediate action required':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_isArabic ? 'تشخيص صحة النبات' : 'Plant Health Diagnosis'),
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
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medical_services_rounded,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isArabic ? 'طبيب النباتات بالذكاء الاصطناعي' : 'AI Plant Doctor',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isArabic
                          ? 'ارفع صورة لنباتك لتشخيص أي مشاكل صحية أو أمراض واحصل على نصائح للعلاج'
                          : 'Upload a photo of your plant to diagnose any health issues or diseases and get treatment advice',
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
                              color: Colors.red.withOpacity(0.3),
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
                                color: Colors.red.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isArabic ? 'اضغط لإضافة صورة النبات' : 'Tap to add plant image',
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

              // Symptoms Input (Optional)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _isArabic ? 'الأعراض (اختياري)' : 'Symptoms (Optional)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _symptomsController,
                      maxLines: 3,
                      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: _isArabic
                            ? 'صف أي أعراض لاحظتها (مثل: أوراق صفراء، بقع، ذبول...)'
                            : 'Describe any symptoms you noticed (e.g., yellow leaves, spots, wilting...)',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Diagnose Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _diagnosePlant,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.search_rounded),
                label: Text(
                  _isLoading
                      ? (_isArabic ? 'جاري التشخيص...' : 'Diagnosing...')
                      : (_isArabic ? 'تشخيص النبات' : 'Diagnose Plant'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                        _isArabic ? 'فشل التشخيص' : 'Diagnosis Failed',
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
                    ],
                  ),
                ),

              // Result Display
              if (_result != null) ...[
                _buildHealthSummaryCard(),
                const SizedBox(height: 16),
                if (_result!.hasIssues && _result!.issues.isNotEmpty) ...[
                  _buildIssuesCard(),
                  const SizedBox(height: 16),
                ],
                _buildAdviceCard(),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummaryCard() {
    final healthColor = _getHealthColor(_result!.overallHealth);
    final urgencyColor = _getUrgencyColor(_result!.urgency);
    final urgencyIcon = _getUrgencyIcon(_result!.urgency);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: healthColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _result!.hasIssues ? Icons.healing_rounded : Icons.favorite_rounded,
                  color: healthColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic ? 'حالة الصحة العامة' : 'Overall Health Status',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      _result!.overallHealth,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: healthColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: urgencyColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(urgencyIcon, color: urgencyColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isArabic ? 'مستوى الإلحاح' : 'Urgency Level',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        _result!.urgency,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: urgencyColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                _isArabic ? 'المشاكل المكتشفة' : 'Detected Issues',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_result!.issues.length}',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_result!.issues.map((issue) => _buildIssueItem(issue))),
        ],
      ),
    );
  }

  Widget _buildIssueItem(PlantIssue issue) {
    final severityColor = _getSeverityColor(issue.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Issue Header
          Row(
            children: [
              Expanded(
                child: Text(
                  issue.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  issue.severity,
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              issue.type,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            issue.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Cause
          _buildIssueDetail(
            Icons.help_outline_rounded,
            _isArabic ? 'السبب' : 'Cause',
            issue.cause,
            Colors.blue,
          ),

          // Treatment
          _buildIssueDetail(
            Icons.medical_services_outlined,
            _isArabic ? 'العلاج' : 'Treatment',
            issue.treatment,
            Colors.green,
          ),

          // Prevention
          _buildIssueDetail(
            Icons.shield_outlined,
            _isArabic ? 'الوقاية' : 'Prevention',
            issue.prevention,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildIssueDetail(IconData icon, String title, String content, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                _isArabic ? 'نصائح عامة' : 'General Advice',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _result!.generalAdvice,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


