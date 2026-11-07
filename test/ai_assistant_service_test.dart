import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/core/ai/ai_assistant_config.dart';
import 'package:streak_reader/src/core/ai/ai_assistant_service.dart';

void main() {
  test('assistant is disabled without an endpoint', () {
    expect(AiAssistantConfig.isConfigured, isFalse);
    expect(const AiAssistantService().isConfigured, isFalse);
  });

  test('does not send requests when unconfigured', () {
    expect(
      () => const AiAssistantService().ask(
        question: 'Explain this',
        bookTitle: 'A book',
        selectedText: 'A selected passage',
      ),
      throwsStateError,
    );
  });
}
