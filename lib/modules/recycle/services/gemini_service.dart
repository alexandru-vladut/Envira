import 'dart:convert';
import 'package:flutter_app_base/core/app_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = AppConfig.geminiApiKey;
  static late final GenerativeModel _model;

  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
  }

  static Future<GeminiResult> analyzeProductRecyclability({
    required String title,
    required String brand,
    required String category,
    required String material,
    required String description,
  }) async {
    // Debug print to see what we're sending
    // print('🔍 Analyzing product:');
    // print('Title: $title');
    // print('Brand: $brand');
    // print('Category: $category');
    // print('Material: $material');
    // print('Description: $description');

    final prompt = _buildAnalysisPrompt(
      title: title,
      brand: brand,
      category: category,
      material: material,
      description: description,
    );

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      // Debug print the raw response
      print('🤖 Gemini raw response: ${response.text}');

      final result = _parseAiResponse(response.text ?? '');
    
      // Debug print the parsed result
      print('📊 Parsed result: ${result.isRecyclable ? "Recyclable" : "Not recyclable"}, ${result.points} points');
      print('Reasoning: ${result.reasoning}');
      
      return result;
    } catch (error) {
      // Fallback to basic logic if AI fails
      return GeminiResult(
        isRecyclable: _basicRecyclabilityCheck(category, material),
        points: _basicPointsCalculation(category, material),
        category: category.isEmpty ? 'Unknown' : category,
        material: material.isEmpty ? 'Unknown' : material,
        description: description.isEmpty ? 'No description available' : description,
        reasoning: 'AI analysis failed, using basic logic: $error',
      );
    }
  }

  /// Builds scientific recyclability analysis prompt based on 2024-2025 studies
  static String _buildAnalysisPrompt({
    required String title,
    required String brand,
    required String category,
    required String material,
    required String description,
    String region = 'EU', // US, EU, Global
  }) {
    // Build dynamic product info section
    String productInfo = '''
Product Information (Guaranteed):
- Title: $title
- Brand: $brand
- Region: $region (affects recycling infrastructure)
''';

    String missingFields = '';
    if (category.isEmpty) {
      missingFields += '- Category: [MISSING - Please determine from internet research]\n';
    } else {
      productInfo += '- Category: $category\n';
    }
    
    if (material.isEmpty) {
      missingFields += '- Material: [MISSING - Please determine from internet research]\n';
    } else {
      productInfo += '- Material: $material\n';
    }
    
    if (description.isEmpty) {
      missingFields += '- Description: [MISSING - Please provide from internet research]\n';
    } else {
      productInfo += '- Description: $description\n';
    }

    return '''
You are an expert environmental analyst specializing in recyclability assessment based on 2024-2025 scientific data. Your task is to research this specific product and analyze its recyclability potential.

$productInfo
${missingFields.isNotEmpty ? '\nMissing Information to Research:\n$missingFields' : ''}

CRITICAL INSTRUCTIONS:
1. Research this EXACT product ("$title" by "$brand") on the internet
2. Analyze BOTH packaging AND product materials for comprehensive assessment
3. Base scoring on 2024-2025 recycling infrastructure and actual recovery rates
4. Consider regional recycling capabilities for $region
5. If any product information is missing above, research and provide accurate values
6. ALL responses must be in English, regardless of original product language

SCIENTIFIC BASIS (2024-2025 Data):
Use the following verified recycling data for scoring:

TIER 1 - EXCELLENT RECYCLABILITY (16-20 points):
- Aluminum cans: 94% carbon savings vs virgin, 43% US recovery rate (2023)
  * CO2 savings: ~9.0 kg CO2e per kg recycled
  * Points: 18-20 (most valuable recyclable material)

- Steel/tin cans: 80% CO2 reduction vs virgin, 85% recovery rate
  * CO2 savings: ~1.5 kg CO2e per kg recycled  
  * Points: 16-18 (highly recyclable, infinite cycles)

TIER 2 - GOOD RECYCLABILITY (11-15 points):
- Clear PET bottles (#1): 71% GHG reduction, 29% US recovery rate (2023)
  * CO2 savings: ~1.7 kg CO2e per kg recycled
  * Points: 13-15 (good material, but low recovery)

- HDPE containers (#2): Good recyclability, ~30% recovery rate
  * CO2 savings: ~1.2 kg CO2e per kg recycled
  * Points: 11-13

- Clear glass bottles: Infinitely recyclable, 39.6% recovery rate
  * CO2 savings: ~0.8 kg CO2e per kg recycled  
  * Points: 11-13

TIER 3 - MODERATE RECYCLABILITY (6-10 points):
- Cardboard/paper: 83.2% EU recovery rate, but quality degrades
  * CO2 savings: ~0.9 kg CO2e per kg recycled
  * Points: 8-10

- Colored PET bottles: Lower sorting efficiency
  * Points: 6-8

TIER 4 - LIMITED RECYCLABILITY (3-5 points):
- Mixed plastics: 41% EU recovery rate, contamination issues
  * Points: 3-5

TIER 5 - POOR/NO RECYCLABILITY (0-2 points):
- Multi-layer packaging (chip bags, candy wrappers): <2% recovery
- Complex composites that cannot be separated
- Points: 0-2

SCORING METHODOLOGY:
Calculate points using this formula:
Base Points = (Material Type Base Score) × (Regional Recovery Rate) × (Quality Factor)

Regional Recovery Rate Modifiers for $region:
- US: Standard baseline (use rates above)
- EU: +15% for most materials (better infrastructure)  
- Global: -10% (conservative estimate)

Quality Factors:
- Clear, single-material packaging: 1.0
- Colored but single-material: 0.8
- Mixed materials, separable: 0.6
- Mixed materials, non-separable: 0.1

ENVIRONMENTAL IMPACT CALCULATION:
Each point represents approximately 0.2 kg CO2e savings based on:
- Energy savings from recycling vs virgin production
- Transportation impact reduction  
- Landfill avoidance
- Resource extraction prevention

OUTPUT FORMAT - Respond with ONLY this JSON:
{
  "isRecyclable": [true if points >= 3, false otherwise],
  "points": [0-20 following scientific guidelines above],
  "category": "[Product category from research]",
  "material": "[Primary materials - both product and packaging]",
  "description": "[Product description from research]",
  "primaryMaterial": "[Main recyclable component]",
  "co2eSavingsKg": [points × 0.2],
  "recoveryRatePercent": "[Estimated % that will actually be recycled in $region]",
  "reasoning": "[Scientific explanation referencing 2024-2025 data and specific recovery rates]",
  "studyBasis": "Based on 2024-2025 recycling infrastructure data and International Aluminum Institute, EPA, and EU recycling statistics"
}

REMEMBER: Base all calculations on actual 2024-2025 environmental science data and regional recycling capabilities!
''';
  }

  static GeminiResult _parseAiResponse(String response) {
    try {
      // Clean the response to extract JSON
      String cleanResponse = response.trim();
      
      // Find JSON content between braces
      int startIndex = cleanResponse.indexOf('{');
      int endIndex = cleanResponse.lastIndexOf('}');
      
      if (startIndex != -1 && endIndex != -1) {
        cleanResponse = cleanResponse.substring(startIndex, endIndex + 1);
      }

      final jsonData = json.decode(cleanResponse);
      
      return GeminiResult(
        isRecyclable: jsonData['isRecyclable'] ?? false,
        points: (jsonData['points'] as num?)?.round() ?? 0,
        category: jsonData['category'] ?? 'Unknown',
        material: jsonData['material'] ?? 'Unknown',
        description: jsonData['description'] ?? 'No description available',
        reasoning: jsonData['reasoning'] ?? 'No reasoning provided',
      );
    } catch (error) {
      // Fallback if parsing fails
      return GeminiResult(
        isRecyclable: false,
        points: 0,
        category: 'Unknown',
        material: 'Unknown',
        description: 'Failed to analyze product',
        reasoning: 'Failed to parse AI response: $error',
      );
    }
  }

  static bool _basicRecyclabilityCheck(String category, String material) {
    final recyclableKeywords = [
      'plastic', 'paper', 'cardboard', 'metal', 'aluminum', 'glass'
    ];
    final categoryLower = category.toLowerCase();
    final materialLower = material.toLowerCase();
    
    return recyclableKeywords.any((keyword) =>
        categoryLower.contains(keyword) || materialLower.contains(keyword));
  }

  static int _basicPointsCalculation(String category, String material) {
    return _basicRecyclabilityCheck(category, material) ? 10 : 0;
  }
}

class GeminiResult {
  final bool isRecyclable;
  final int points;
  final String category;
  final String material;
  final String description;
  final String reasoning;

  GeminiResult({
    required this.isRecyclable,
    required this.points,
    required this.category,
    required this.material,
    required this.description,
    required this.reasoning,
  });
}
