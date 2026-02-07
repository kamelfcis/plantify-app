import 'dart:math';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  static AIService get instance => _instance;

  AIService._internal();

  // Mock AI Plant Identification
  Future<PlantIdentificationResult> identifyPlant(String imagePath) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    final mockPlants = [
      {
        'name': 'Monstera Deliciosa',
        'scientificName': 'Monstera deliciosa',
        'confidence': 0.95,
        'careInfo': {
          'watering': 'Water once a week, allow soil to dry between waterings',
          'sunlight': 'Bright, indirect light',
          'humidity': 'High humidity preferred',
          'temperature': '65-85°F',
        },
        'inMarketplace': true,
        'productId': '1',
      },
      {
        'name': 'Snake Plant',
        'scientificName': 'Sansevieria trifasciata',
        'confidence': 0.92,
        'careInfo': {
          'watering': 'Water every 2-3 weeks, very drought tolerant',
          'sunlight': 'Low to bright indirect light',
          'humidity': 'Low humidity is fine',
          'temperature': '60-80°F',
        },
        'inMarketplace': true,
        'productId': '2',
      },
      {
        'name': 'Pothos',
        'scientificName': 'Epipremnum aureum',
        'confidence': 0.88,
        'careInfo': {
          'watering': 'Water when top inch of soil is dry',
          'sunlight': 'Bright, indirect light',
          'humidity': 'Moderate humidity',
          'temperature': '65-75°F',
        },
        'inMarketplace': true,
        'productId': '3',
      },
    ];

    final random = Random();
    final plant = mockPlants[random.nextInt(mockPlants.length)];

    return PlantIdentificationResult(
      name: plant['name'] as String,
      scientificName: plant['scientificName'] as String,
      confidence: plant['confidence'] as double,
      careInfo: PlantCareInfo.fromMap(plant['careInfo'] as Map<String, dynamic>),
      inMarketplace: plant['inMarketplace'] as bool,
      productId: plant['productId'] as String?,
    );
  }

  // Mock AI Plant Diagnosis
  Future<PlantDiagnosisResult> diagnosePlant({
    required String imagePath,
    required String wateringFrequency,
    required String sunlight,
    required String environment,
    required String startDate,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final issues = [
      {
        'diagnosis': 'Overwatering',
        'cause': 'Soil is consistently wet, leading to root rot',
        'treatment': 'Reduce watering frequency. Allow soil to dry completely between waterings. Check for root rot and repot if necessary.',
        'severity': 'Moderate',
      },
      {
        'diagnosis': 'Insufficient Light',
        'cause': 'Plant is not receiving enough sunlight for healthy growth',
        'treatment': 'Move plant to a brighter location with indirect sunlight. Consider using grow lights if natural light is limited.',
        'severity': 'Mild',
      },
      {
        'diagnosis': 'Nutrient Deficiency',
        'cause': 'Lack of essential nutrients in the soil',
        'treatment': 'Fertilize with balanced plant food every 4-6 weeks during growing season. Ensure proper soil pH.',
        'severity': 'Mild',
      },
      {
        'diagnosis': 'Pest Infestation',
        'cause': 'Presence of common plant pests (aphids, spider mites)',
        'treatment': 'Isolate plant. Treat with neem oil or insecticidal soap. Remove affected leaves if necessary.',
        'severity': 'Moderate',
      },
    ];

    final random = Random();
    final issue = issues[random.nextInt(issues.length)];

    return PlantDiagnosisResult(
      diagnosis: issue['diagnosis'] as String,
      cause: issue['cause'] as String,
      treatment: issue['treatment'] as String,
      severity: issue['severity'] as String,
    );
  }
}

class PlantIdentificationResult {
  final String name;
  final String scientificName;
  final double confidence;
  final PlantCareInfo careInfo;
  final bool inMarketplace;
  final String? productId;

  PlantIdentificationResult({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.careInfo,
    required this.inMarketplace,
    this.productId,
  });
}

class PlantCareInfo {
  final String watering;
  final String sunlight;
  final String humidity;
  final String temperature;

  PlantCareInfo({
    required this.watering,
    required this.sunlight,
    required this.humidity,
    required this.temperature,
  });

  factory PlantCareInfo.fromMap(Map<String, dynamic> map) {
    return PlantCareInfo(
      watering: map['watering'] as String,
      sunlight: map['sunlight'] as String,
      humidity: map['humidity'] as String,
      temperature: map['temperature'] as String,
    );
  }
}

class PlantDiagnosisResult {
  final String diagnosis;
  final String cause;
  final String treatment;
  final String severity;

  PlantDiagnosisResult({
    required this.diagnosis,
    required this.cause,
    required this.treatment,
    required this.severity,
  });
}

