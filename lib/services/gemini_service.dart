import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  static GeminiService get instance => _instance;

  GeminiService._internal();

  // API key loaded from .env file (not committed to git)
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  GenerativeModel? _model;

  GenerativeModel get model {
    // Use gemini-2.0-flash for multimodal (image) support
    // Alternative models: gemini-1.5-pro, gemini-pro-vision
    _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
    return _model!;
  }

  /// Identify a plant from an image file
  /// Set [inArabic] to true to get response in Arabic
  Future<PlantIdentificationResponse> identifyPlant(File imageFile, {bool inArabic = false}) async {
    try {
      debugPrint('🌿 Starting plant identification...');
      
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();
      
      // Determine mime type
      final extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      debugPrint('📷 Image size: ${imageBytes.length} bytes, type: $mimeType');

      // Create the prompt for plant identification
      final languageInstruction = inArabic 
          ? '\n\nIMPORTANT: Provide ALL text values in Arabic language (except for scientificName which should remain in Latin). Write descriptions, care instructions, and all other text in Arabic.'
          : '';
      
      final prompt = '''
You are an expert botanist. Analyze this image and identify the plant or flower.

Please provide the following information in JSON format:
{
  "identified": true/false,
  "name": "Common name of the plant",
  "scientificName": "Scientific/Latin name",
  "family": "Plant family",
  "confidence": 0.0-1.0 (your confidence level),
  "description": "Brief description of the plant",
  "characteristics": {
    "type": "Flower/Succulent/Tree/Shrub/Herb/Vine/etc.",
    "leafShape": "Description of leaves",
    "flowerColor": "Color of flowers if applicable",
    "height": "Typical height range"
  },
  "careInstructions": {
    "watering": "Watering instructions",
    "sunlight": "Light requirements",
    "humidity": "Humidity preferences",
    "temperature": "Temperature range",
    "soil": "Soil type",
    "fertilizer": "Fertilizing tips"
  },
  "funFacts": ["Interesting fact 1", "Interesting fact 2"],
  "warnings": "Any toxicity warnings for pets/humans, or null if safe"
}

If you cannot identify the plant or the image doesn't contain a plant, set "identified" to false and provide a helpful message in "description".
$languageInstruction
Respond ONLY with valid JSON, no additional text.
''';

      // Create content with image
      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]);

      debugPrint('🤖 Sending request to Gemini...');
      
      // Generate response
      final response = await model.generateContent([content]);
      final responseText = response.text;

      debugPrint('✅ Received response from Gemini');
      debugPrint('📄 Response: $responseText');

      if (responseText == null || responseText.isEmpty) {
        return PlantIdentificationResponse(
          success: false,
          errorMessage: 'No response received from AI',
        );
      }

      // Parse JSON response
      try {
        // Clean response - remove markdown code blocks if present
        String cleanedResponse = responseText.trim();
        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse.substring(7);
        }
        if (cleanedResponse.startsWith('```')) {
          cleanedResponse = cleanedResponse.substring(3);
        }
        if (cleanedResponse.endsWith('```')) {
          cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
        }
        cleanedResponse = cleanedResponse.trim();

        final jsonData = json.decode(cleanedResponse) as Map<String, dynamic>;
        
        final identified = jsonData['identified'] as bool? ?? false;
        
        if (!identified) {
          return PlantIdentificationResponse(
            success: false,
            errorMessage: jsonData['description'] as String? ?? 'Could not identify the plant',
          );
        }

        return PlantIdentificationResponse(
          success: true,
          plant: IdentifiedPlant.fromJson(jsonData),
        );
      } catch (e) {
        debugPrint('❌ Error parsing JSON: $e');
        debugPrint('📄 Raw response: $responseText');
        return PlantIdentificationResponse(
          success: false,
          errorMessage: 'Error parsing AI response: $e',
        );
      }
    } catch (e) {
      debugPrint('❌ Error identifying plant: $e');
      return PlantIdentificationResponse(
        success: false,
        errorMessage: 'Error: $e',
      );
    }
  }

  /// Diagnose plant health issues from an image
  /// Set [inArabic] to true to get response in Arabic
  Future<PlantDiagnosisResponse> diagnosePlant(File imageFile, {String? symptoms, bool inArabic = false}) async {
    try {
      debugPrint('🔬 Starting plant diagnosis...');
      
      final imageBytes = await imageFile.readAsBytes();
      
      final extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      final languageInstruction = inArabic 
          ? '\n\nIMPORTANT: Provide ALL text values in Arabic language. Write descriptions, treatments, causes, prevention tips, and all other text in Arabic.'
          : '';

      String prompt = '''
You are an expert plant pathologist. Analyze this image of a plant and identify any health issues, diseases, or problems.

${symptoms != null ? 'The user has noted these symptoms: $symptoms\n' : ''}

Please provide the following information in JSON format:
{
  "hasIssues": true/false,
  "overallHealth": "Healthy/Mild Issues/Moderate Issues/Severe Issues",
  "issues": [
    {
      "name": "Name of the issue/disease",
      "type": "Disease/Pest/Nutrient Deficiency/Environmental/Other",
      "severity": "Mild/Moderate/Severe",
      "description": "Description of the problem",
      "cause": "What causes this issue",
      "treatment": "How to treat/fix this issue",
      "prevention": "How to prevent in the future"
    }
  ],
  "generalAdvice": "General care advice for this plant",
  "urgency": "No action needed/Monitor/Act soon/Immediate action required"
}

If the plant appears healthy, set "hasIssues" to false and provide positive feedback.
$languageInstruction
Respond ONLY with valid JSON, no additional text.
''';

      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]);

      debugPrint('🤖 Sending diagnosis request to Gemini...');
      
      final response = await model.generateContent([content]);
      final responseText = response.text;

      debugPrint('✅ Received diagnosis response');

      if (responseText == null || responseText.isEmpty) {
        return PlantDiagnosisResponse(
          success: false,
          errorMessage: 'No response received from AI',
        );
      }

      try {
        String cleanedResponse = responseText.trim();
        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse.substring(7);
        }
        if (cleanedResponse.startsWith('```')) {
          cleanedResponse = cleanedResponse.substring(3);
        }
        if (cleanedResponse.endsWith('```')) {
          cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
        }
        cleanedResponse = cleanedResponse.trim();

        final jsonData = json.decode(cleanedResponse) as Map<String, dynamic>;
        
        return PlantDiagnosisResponse(
          success: true,
          diagnosis: PlantDiagnosis.fromJson(jsonData),
        );
      } catch (e) {
        debugPrint('❌ Error parsing diagnosis JSON: $e');
        return PlantDiagnosisResponse(
          success: false,
          errorMessage: 'Error parsing AI response: $e',
        );
      }
    } catch (e) {
      debugPrint('❌ Error diagnosing plant: $e');
      return PlantDiagnosisResponse(
        success: false,
        errorMessage: 'Error: $e',
      );
    }
  }

  /// Chat with AI assistant about plants
  /// Supports text messages and optional image attachment
  Future<ChatResponse> chat({
    required String message,
    File? imageFile,
    List<ChatMessage>? history,
    bool inArabic = false,
  }) async {
    try {
      debugPrint('💬 Starting chat...');

      final languageInstruction = inArabic
          ? 'IMPORTANT: Respond in Arabic language.'
          : '';

      final systemPrompt = '''
You are a friendly and knowledgeable plant care assistant called "Plantify Assistant". 
You help users with:
- Plant identification
- Plant care advice (watering, sunlight, soil, etc.)
- Diagnosing plant health issues
- General gardening tips
- Answering questions about plants and flowers

Be helpful, concise, and friendly. If an image is provided, analyze it carefully.
If you're unsure about something, say so honestly.
$languageInstruction
''';

      List<Part> parts = [TextPart('$systemPrompt\n\nUser: $message')];

      // Add image if provided
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        final extension = imageFile.path.split('.').last.toLowerCase();
        String mimeType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            mimeType = 'image/jpeg';
        }
        parts.add(DataPart(mimeType, imageBytes));
        debugPrint('📷 Image attached: ${imageBytes.length} bytes');
      }

      final content = Content.multi(parts);

      debugPrint('🤖 Sending chat message to Gemini...');
      final response = await model.generateContent([content]);
      final responseText = response.text;

      debugPrint('✅ Received chat response');

      if (responseText == null || responseText.isEmpty) {
        return ChatResponse(
          success: false,
          errorMessage: 'No response received from AI',
        );
      }

      return ChatResponse(
        success: true,
        message: responseText.trim(),
      );
    } catch (e) {
      debugPrint('❌ Error in chat: $e');
      return ChatResponse(
        success: false,
        errorMessage: 'Error: $e',
      );
    }
  }
}

// Chat classes
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final String? imagePath;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatResponse {
  final bool success;
  final String? message;
  final String? errorMessage;

  ChatResponse({
    required this.success,
    this.message,
    this.errorMessage,
  });
}

// Response classes
class PlantIdentificationResponse {
  final bool success;
  final IdentifiedPlant? plant;
  final String? errorMessage;

  PlantIdentificationResponse({
    required this.success,
    this.plant,
    this.errorMessage,
  });
}

class IdentifiedPlant {
  final String name;
  final String scientificName;
  final String family;
  final double confidence;
  final String description;
  final PlantCharacteristics characteristics;
  final PlantCareInstructions careInstructions;
  final List<String> funFacts;
  final String? warnings;

  IdentifiedPlant({
    required this.name,
    required this.scientificName,
    required this.family,
    required this.confidence,
    required this.description,
    required this.characteristics,
    required this.careInstructions,
    required this.funFacts,
    this.warnings,
  });

  factory IdentifiedPlant.fromJson(Map<String, dynamic> json) {
    return IdentifiedPlant(
      name: json['name'] as String? ?? 'Unknown Plant',
      scientificName: json['scientificName'] as String? ?? '',
      family: json['family'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      characteristics: PlantCharacteristics.fromJson(
        json['characteristics'] as Map<String, dynamic>? ?? {},
      ),
      careInstructions: PlantCareInstructions.fromJson(
        json['careInstructions'] as Map<String, dynamic>? ?? {},
      ),
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      warnings: json['warnings'] as String?,
    );
  }
}

class PlantCharacteristics {
  final String type;
  final String leafShape;
  final String flowerColor;
  final String height;

  PlantCharacteristics({
    required this.type,
    required this.leafShape,
    required this.flowerColor,
    required this.height,
  });

  factory PlantCharacteristics.fromJson(Map<String, dynamic> json) {
    return PlantCharacteristics(
      type: json['type'] as String? ?? '',
      leafShape: json['leafShape'] as String? ?? '',
      flowerColor: json['flowerColor'] as String? ?? '',
      height: json['height'] as String? ?? '',
    );
  }
}

class PlantCareInstructions {
  final String watering;
  final String sunlight;
  final String humidity;
  final String temperature;
  final String soil;
  final String fertilizer;

  PlantCareInstructions({
    required this.watering,
    required this.sunlight,
    required this.humidity,
    required this.temperature,
    required this.soil,
    required this.fertilizer,
  });

  factory PlantCareInstructions.fromJson(Map<String, dynamic> json) {
    return PlantCareInstructions(
      watering: json['watering'] as String? ?? '',
      sunlight: json['sunlight'] as String? ?? '',
      humidity: json['humidity'] as String? ?? '',
      temperature: json['temperature'] as String? ?? '',
      soil: json['soil'] as String? ?? '',
      fertilizer: json['fertilizer'] as String? ?? '',
    );
  }
}

// Diagnosis classes
class PlantDiagnosisResponse {
  final bool success;
  final PlantDiagnosis? diagnosis;
  final String? errorMessage;

  PlantDiagnosisResponse({
    required this.success,
    this.diagnosis,
    this.errorMessage,
  });
}

class PlantDiagnosis {
  final bool hasIssues;
  final String overallHealth;
  final List<PlantIssue> issues;
  final String generalAdvice;
  final String urgency;

  PlantDiagnosis({
    required this.hasIssues,
    required this.overallHealth,
    required this.issues,
    required this.generalAdvice,
    required this.urgency,
  });

  factory PlantDiagnosis.fromJson(Map<String, dynamic> json) {
    return PlantDiagnosis(
      hasIssues: json['hasIssues'] as bool? ?? false,
      overallHealth: json['overallHealth'] as String? ?? 'Unknown',
      issues: (json['issues'] as List<dynamic>?)
              ?.map((e) => PlantIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generalAdvice: json['generalAdvice'] as String? ?? '',
      urgency: json['urgency'] as String? ?? '',
    );
  }
}

class PlantIssue {
  final String name;
  final String type;
  final String severity;
  final String description;
  final String cause;
  final String treatment;
  final String prevention;

  PlantIssue({
    required this.name,
    required this.type,
    required this.severity,
    required this.description,
    required this.cause,
    required this.treatment,
    required this.prevention,
  });

  factory PlantIssue.fromJson(Map<String, dynamic> json) {
    return PlantIssue(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cause: json['cause'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      prevention: json['prevention'] as String? ?? '',
    );
  }
}

