import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../providers/books_providers.dart';

class EditTitleDialog extends ConsumerStatefulWidget {
  final int bookId;
  final String currentTitle;

  const EditTitleDialog({
    super.key,
    required this.bookId,
    required this.currentTitle,
  });

  @override
  ConsumerState<EditTitleDialog> createState() => _EditTitleDialogState();
}

class _EditTitleDialogState extends ConsumerState<EditTitleDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = l10n.titleRequired);
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await ref.read(booksRepositoryProvider).updateTitle(widget.bookId, title);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
      return;
    }

    if (!mounted) return;
    ref.invalidate(booksListProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.editTitle)),
        ],
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        decoration: InputDecoration(
          labelText: l10n.bookTitle,
          prefixIcon: const Icon(Icons.menu_book_outlined),
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}
