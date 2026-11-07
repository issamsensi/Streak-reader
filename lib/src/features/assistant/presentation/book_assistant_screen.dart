import 'package:flutter/material.dart';

import '../../../core/ai/ai_assistant_service.dart';

class BookAssistantScreen extends StatefulWidget {
  const BookAssistantScreen({
    super.key,
    required this.bookTitle,
    this.selectedText,
    this.notes,
  });

  final String bookTitle;
  final String? selectedText;
  final String? notes;

  @override
  State<BookAssistantScreen> createState() => _BookAssistantScreenState();
}

class _BookAssistantScreenState extends State<BookAssistantScreen> {
  final _questionController = TextEditingController();
  final _messages = <_AssistantMessage>[];
  bool _busy = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _busy) return;
    _questionController.clear();
    setState(() {
      _messages.add(_AssistantMessage(question, true));
      _busy = true;
    });
    try {
      final answer = await const AiAssistantService().ask(
        question: question,
        bookTitle: widget.bookTitle,
        selectedText: widget.selectedText,
        notes: widget.notes,
      );
      if (mounted) {
        setState(() => _messages.add(_AssistantMessage(answer, false)));
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _messages.add(
            _AssistantMessage('Assistant unavailable: $error', false),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = const AiAssistantService().isConfigured;
    return Scaffold(
      appBar: AppBar(title: const Text('Book assistant')),
      body: Column(
        children: [
          if (!configured)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'The assistant is optional and disabled until an AI endpoint is configured.',
              ),
            ),
          if (widget.selectedText != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Selected passage:\n${widget.selectedText}',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.fromUser
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Card(
                    color: message.fromUser
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(message.text),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      enabled: configured && !_busy,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _ask(),
                      decoration: const InputDecoration(
                        hintText: 'Ask about this book or passage…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: configured && !_busy ? _ask : null,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantMessage {
  const _AssistantMessage(this.text, this.fromUser);

  final String text;
  final bool fromUser;
}
