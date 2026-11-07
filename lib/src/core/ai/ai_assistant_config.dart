class AiAssistantConfig {
  const AiAssistantConfig._();

  static const endpoint = String.fromEnvironment('AI_ASSISTANT_URL');
  static const apiKey = String.fromEnvironment('AI_ASSISTANT_API_KEY');

  static bool get isConfigured => endpoint.isNotEmpty;
}
