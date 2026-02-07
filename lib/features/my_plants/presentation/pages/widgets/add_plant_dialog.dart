import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/gradient_button.dart';
import '../../../../../../core/utils/image_helper.dart';
import '../../../../../../services/supabase_service.dart';
import '../my_plants_page.dart';

class AddPlantDialog extends StatefulWidget {
  const AddPlantDialog({super.key});

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  XFile? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final image = await ImageHelper.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _takePhoto() async {
    final image = await ImageHelper.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Plant',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                // Image Picker Section
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add plant image',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Plant Name',
                    prefixIcon: Icon(Icons.local_florist),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'scientificName',
                  decoration: const InputDecoration(
                    labelText: 'Scientific Name (Optional)',
                    prefixIcon: Icon(Icons.science),
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'health',
                  decoration: const InputDecoration(
                    labelText: 'Health Status',
                    prefixIcon: Icon(Icons.health_and_safety),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Excellent', child: Text('Excellent')),
                    DropdownMenuItem(value: 'Good', child: Text('Good')),
                    DropdownMenuItem(value: 'Fair', child: Text('Fair')),
                    DropdownMenuItem(value: 'Poor', child: Text('Poor')),
                  ],
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderSlider(
                  name: 'growth',
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: 'Growth: {value}%',
                  initialValue: 50,
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'dateAdded',
                  decoration: const InputDecoration(
                    labelText: 'Date Added',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  inputType: InputType.date,
                  format: DateFormat('yyyy-MM-dd'),
                  initialValue: DateTime.now(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'nextWatering',
                  decoration: const InputDecoration(
                    labelText: 'Next Watering Date',
                    prefixIcon: Icon(Icons.water_drop),
                  ),
                  inputType: InputType.date,
                  format: DateFormat('yyyy-MM-dd'),
                  initialValue: DateTime.now().add(const Duration(days: 3)),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientButton(
                        text: _isUploading ? 'Uploading...' : 'Add Plant',
                        onPressed: _isUploading ? null : () async {
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            setState(() => _isUploading = true);
                            
                            try {
                              String? imageUrl;
                              
                              // Upload image if selected
                              if (_selectedImage != null) {
                                try {
                                  imageUrl = await SupabaseService.instance.uploadPlantImage(
                                    _selectedImage!.path,
                                    _selectedImage!.name,
                                  );
                                } catch (e) {
                                  debugPrint('Error uploading image: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error uploading image: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              }
                              
                              // Create plant in database
                              final data = _formKey.currentState!.value;
                              
                              // Format dates properly for database
                              final dateAdded = data['dateAdded'] as DateTime?;
                              final nextWatering = data['nextWatering'] as DateTime?;
                              
                              final plantResponse = await SupabaseService.instance.createUserPlant(
                                name: data['name'] as String,
                                scientificName: data['scientificName'] as String?,
                                healthStatus: data['health'] as String,
                                growthPercentage: (data['growth'] as num).toInt(),
                                dateAdded: dateAdded != null 
                                    ? DateFormat('yyyy-MM-dd').format(dateAdded)
                                    : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                nextWateringDate: nextWatering != null 
                                    ? DateFormat('yyyy-MM-dd').format(nextWatering)
                                    : null,
                                imageUrl: imageUrl,
                              );
                              
                              final plant = PlantData.fromMap(plantResponse);
                              
                              if (mounted) {
                                Navigator.pop(context, plant);
                              }
                            } catch (e) {
                              debugPrint('Error creating plant: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error creating plant: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                setState(() => _isUploading = false);
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

