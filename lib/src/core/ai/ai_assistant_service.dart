import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_assistant_config.dart';

class AiAssistantService {
  const AiAssistantService();

  bool get isConfigured => AiAssistantConfig.isConfigured;

  Future<String> ask({
    required String question,
    required String bookTitle,
    String? selectedText,
    String? notes,
  }) async {
    if (!isConfigured) {
      throw StateError(
        'The AI assistant is not configured. '
        'Set AI_ASSISTANT_URL at build time to enable it.',
      );
    }
    final response = await http
        .post(
          Uri.parse(AiAssistantConfig.endpoint),
          headers: {
            'Content-Type': 'application/json',
            if (AiAssistantConfig.apiKey.isNotEmpty)
              'Authorization': 'Bearer ${AiAssistantConfig.apiKey}',
          },
          body: jsonEncode({
            'bookTitle': bookTitle,
            'question': question,
            if (selectedText != null && selectedText.trim().isNotEmpty)
              'selectedText': selectedText,
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes,
          }),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('AI assistant request failed (${response.statusCode}).');
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['answer'] is! String) {
      throw const FormatException('AI assistant returned an invalid response.');
    }
    return (data['answer'] as String).trim();
  }
}
