import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AiService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Generates a wellness or therapeutic insight based on user inputs.
  /// Decouples model definitions and system instructions from client code
  /// by fetching them from Firebase Remote Config variables.
  Future<String> generateWellnessInsight(String userPrompt) async {
    // 1. Fetch server-configured parameters
    final modelName = _remoteConfig.getString('ai_model_name').isNotEmpty
        ? _remoteConfig.getString('ai_model_name')
        : 'gemini-1.5-flash';

    final systemInstruction =
        _remoteConfig.getString('ai_system_instruction').isNotEmpty
        ? _remoteConfig.getString('ai_system_instruction')
        : 'You are Divinity, a helpful and calm wellness academy coach.';

    try {
      // 2. Initialize Gemini Developer API provider (Spark plan compatible)
      final ai = FirebaseAI.googleAI();
      final model = ai.generativeModel(
        model: modelName,
        systemInstruction: Content.system(systemInstruction),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1000,
        ),
      );

      // 3. Submit client prompt to Gemini API via secure proxy
      final response = await model.generateContent([Content.text(userPrompt)]);

      return response.text ?? 'No insight generated.';
    } catch (e) {
      debugPrint('[AI Service] Error generating content: $e');
      return 'Could not connect to the wellness assistant. Please try again later.';
    }
  }
}
