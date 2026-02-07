import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/glass_card.dart';

class WaterCalculatorCard extends StatefulWidget {
  const WaterCalculatorCard({super.key});

  @override
  State<WaterCalculatorCard> createState() => _WaterCalculatorCardState();
}

class _WaterCalculatorCardState extends State<WaterCalculatorCard> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _result;

  void _calculateWater() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final plantType = formData['plantType'] as String;
      final potSize = formData['potSize'] as String;
      final environment = formData['environment'] as String;

      // Simple calculation logic
      double baseAmount = 0;
      switch (potSize) {
        case 'Small (4-6 inches)':
          baseAmount = 0.5;
          break;
        case 'Medium (6-8 inches)':
          baseAmount = 1.0;
          break;
        case 'Large (8+ inches)':
          baseAmount = 1.5;
          break;
      }

      if (environment == 'Outdoor') {
        baseAmount *= 1.5;
      }

      setState(() {
        _result = 'Recommended: ${baseAmount.toStringAsFixed(1)} cups (${(baseAmount * 236.588).toStringAsFixed(0)} ml) per week';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.water_drop, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Calculator',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calculate optimal watering',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderDropdown<String>(
                  name: 'plantType',
                  decoration: const InputDecoration(
                    labelText: 'Plant Type',
                    prefixIcon: Icon(Icons.local_florist),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Succulent', child: Text('Succulent')),
                    DropdownMenuItem(value: 'Tropical', child: Text('Tropical')),
                    DropdownMenuItem(value: 'Herb', child: Text('Herb')),
                    DropdownMenuItem(value: 'Flowering', child: Text('Flowering')),
                  ],
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'potSize',
                  decoration: const InputDecoration(
                    labelText: 'Pot Size',
                    prefixIcon: Icon(Icons.square_foot),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Small (4-6 inches)', child: Text('Small (4-6 inches)')),
                    DropdownMenuItem(value: 'Medium (6-8 inches)', child: Text('Medium (6-8 inches)')),
                    DropdownMenuItem(value: 'Large (8+ inches)', child: Text('Large (8+ inches)')),
                  ],
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'environment',
                  decoration: const InputDecoration(
                    labelText: 'Environment',
                    prefixIcon: Icon(Icons.home),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Indoor', child: Text('Indoor')),
                    DropdownMenuItem(value: 'Outdoor', child: Text('Outdoor')),
                  ],
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculateWater,
                    child: const Text('Calculate'),
                  ),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _result!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

