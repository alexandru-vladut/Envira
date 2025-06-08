import 'dart:convert';
import 'package:flutter_app_base/core/app_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = AppConfig.geminiApiKey;
  static late final GenerativeModel _model;

  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
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
    print('🔍 Analyzing product:');
    print('Title: $title');
    print('Brand: $brand');
    print('Category: $category');
    print('Material: $material');
    print('Description: $description');

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

  static String _buildAnalysisPrompt({
    required String title,
    required String brand,
    required String category,
    required String material,
    required String description,
  }) {
    // Build dynamic product info section
    String productInfo = '''
  Product Information (Guaranteed):
  - Title: $title
  - Brand: $brand
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
  You are an expert environmental analyst specializing in PACKAGING recyclability assessment. Your task is to research this specific product and analyze the RECYCLABILITY OF ITS PACKAGING, not the product contents.

  $productInfo
  ${missingFields.isNotEmpty ? '\nMissing Information to Research:\n$missingFields' : ''}

  CRITICAL INSTRUCTIONS:
  1. Research this EXACT product ("$title" by "$brand") on the internet
  2. Focus ONLY on the PACKAGING materials and recyclability, NOT the product contents
  3. For consumable products (food, drinks, cosmetics): analyze bottles, cans, boxes, wrappers, containers
  4. For non-consumable products: analyze the primary material of the product itself
  5. If any product information is missing above, research and provide accurate values
  6. ALL responses must be in English, regardless of original product language
  7. Focus on MODERN recycling capabilities (2023-2025 standards)

  PACKAGING ANALYSIS GUIDELINES:
  Research and determine the packaging materials for this specific product:

  Common RECYCLABLE packaging and point ranges:
  - PET plastic bottles (water, soda, juice): 15-18 points - HIGHLY RECYCLABLE
  - Aluminum cans/containers (beverages, food): 18-20 points - MOST RECYCLABLE
  - Glass bottles/jars (beverages, food): 14-17 points - HIGHLY RECYCLABLE
  - HDPE containers (milk jugs, detergent): 12-16 points - VERY RECYCLABLE
  - Cardboard boxes/packaging: 10-15 points - GENERALLY RECYCLABLE
  - Steel/tin cans (food, aerosols): 14-17 points - HIGHLY RECYCLABLE

  Common NON-RECYCLABLE or DIFFICULT packaging:
  - Multi-layer packaging (chip bags, candy wrappers): 0-2 points
  - Mixed material packaging (juice boxes with plastic spouts): 1-5 points
  - Plastic films and flexible packaging: 0-3 points
  - Styrofoam/polystyrene containers: 0-1 points

  EXAMPLES OF PROPER ANALYSIS:
  - "Coca-Cola bottle" → Analyze: PET plastic bottle → 16 points, recyclable
  - "Snickers chocolate bar" → Analyze: Plastic wrapper → 1 point, not recyclable
  - "Heinz ketchup" → Analyze: Glass bottle or plastic squeeze bottle → 15-17 points, recyclable
  - "Lay's potato chips" → Analyze: Multi-layer plastic bag → 1 point, not recyclable
  - "iPhone case" → Analyze: Product itself (plastic/silicone) → varies based on material

  POINTS SYSTEM (Packaging Recyclability Value):
  - 0 points: NOT recyclable (complex composites, multi-layer films)
  - 1-5 points: Very limited recyclability, specialized facilities only
  - 6-10 points: Some recyclability with effort or pre-processing
  - 11-15 points: Good recyclability in most modern programs
  - 16-20 points: Excellent recyclability, high value materials, easy processing

  Consider packaging RECYCLABLE if:
  - The primary packaging material is accepted by major recycling programs
  - Standard municipal recycling programs can process it
  - The packaging doesn't have complex multi-material construction

  OUTPUT FORMAT - Respond with ONLY this JSON:
  {
    "isRecyclable": [true/false - based on packaging analysis],
    "points": [0-20 following guidelines above],
    "category": "[Product category from research]",
    "material": "[Primary PACKAGING material from research]", 
    "description": "[Product description from research]",
    "reasoning": "[Brief explanation focusing on PACKAGING materials and why they are/aren't recyclable]"
  }

  REMEMBER: Always analyze the PACKAGING, not the consumable contents!
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
        points: jsonData['isRecyclable'] == false ? 0 : (jsonData['points'] ?? 0).clamp(0, 20),
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
