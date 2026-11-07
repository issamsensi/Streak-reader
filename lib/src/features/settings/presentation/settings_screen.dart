import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/monthly_goal.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Native language names stay untranslated in every locale.
  static const _languages = [
    ('ar', 'العربية'),
    ('en', 'English'),
    ('fr', 'Français'),
  ];

  Future<void> _showCustomGoalDialog(
    BuildContext context,
    WidgetRef ref,
    int initialMinutes,
  ) async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (_) => _CustomGoalDialog(initialMinutes: initialMinutes),
    );
    if (minutes == null) return;
    await ref.read(settingsProvider.notifier).setDailyGoal(minutes);
  }

  Future<void> _showMonthlyGoalsDialog(
    BuildContext context,
    WidgetRef ref,
    MonthlyGoal initial,
  ) async {
    final goal = await showDialog<MonthlyGoal>(
      context: context,
      builder: (_) => _MonthlyGoalsDialog(initial: initial),
    );
    if (goal != null) {
      await ref
          .read(settingsProvider.notifier)
          .setMonthlyGoal(DateTime.now(), goal);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final isCustomGoal =
        !AppConstants.dailyGoalPresets.contains(settings.dailyGoalMinutes);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _SettingsSection(
            icon: Icons.translate_rounded,
            title: l10n.language,
            child: RadioGroup<String>(
              groupValue: settings.languageCode,
              onChanged: (value) {
                if (value != null) controller.setLanguage(value);
              },
              child: Column(
                children: [
                  for (final (code, name) in _languages)
                    RadioListTile<String>(
                      value: code,
                      title: Text(name),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            icon: Icons.flag_rounded,
            title: l10n.dailyReadingGoal,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyGoalDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final minutes in AppConstants.dailyGoalPresets)
                        ChoiceChip(
                          label: Text('$minutes ${l10n.minute}'),
                          selected: !isCustomGoal &&
                              settings.dailyGoalMinutes == minutes,
                          onSelected: (_) => controller.setDailyGoal(minutes),
                        ),
                      ChoiceChip(
                        avatar: const Icon(Icons.edit_rounded, size: 16),
                        label: Text(l10n.customGoal),
                        selected: isCustomGoal,
                        onSelected: (_) => _showCustomGoalDialog(
                          context,
                          ref,
                          settings.dailyGoalMinutes,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.currentGoal}: '
                    '${settings.dailyGoalMinutes} ${l10n.minute}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            icon: Icons.insights_rounded,
            title: l10n.monthlyGoals,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.monthlyGoalDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showMonthlyGoalsDialog(
                      context,
                      ref,
                      settings.monthlyGoalHistory.goalFor(DateTime.now()),
                    ),
                    child: Text(l10n.configure),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            icon: Icons.palette_outlined,
            title: l10n.theme,
            child: RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) controller.setThemeMode(value);
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: Text(l10n.themeSystem),
                    secondary: Icon(
                      Icons.brightness_auto_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text(l10n.themeLight),
                    secondary: Icon(
                      Icons.light_mode_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text(l10n.themeDark),
                    secondary: Icon(
                      Icons.dark_mode_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 30,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Streak Reader',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: AppTheme.displayFont,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class _MonthlyGoalsDialog extends StatefulWidget {
  final MonthlyGoal initial;

  const _MonthlyGoalsDialog({required this.initial});

  @override
  State<_MonthlyGoalsDialog> createState() => _MonthlyGoalsDialogState();
}

class _MonthlyGoalsDialogState extends State<_MonthlyGoalsDialog> {
  late final Map<MonthlyGoalType, TextEditingController> _controllers;
  late final Set<MonthlyGoalType> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial.targets.keys.toSet();
    _controllers = {
      for (final type in MonthlyGoalType.values)
        type: TextEditingController(
          text: '${widget.initial.targets[type] ?? _suggested(type)}',
        ),
    };
  }

  static int _suggested(MonthlyGoalType type) => switch (type) {
        MonthlyGoalType.minutes => 600,
        MonthlyGoalType.pages => 100,
        MonthlyGoalType.books => 1,
      };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.monthlyGoals),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final type in MonthlyGoalType.values)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _selected.contains(type),
                title: Text(switch (type) {
                  MonthlyGoalType.minutes => l10n.monthlyMinutes,
                  MonthlyGoalType.pages => l10n.monthlyPages,
                  MonthlyGoalType.books => l10n.monthlyBooks,
                }),
                onChanged: (selected) => setState(() {
                  if (selected == true) {
                    _selected.add(type);
                  } else {
                    _selected.remove(type);
                  }
                }),
              ),
            for (final type in _selected)
              TextField(
                controller: _controllers[type],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: switch (type) {
                    MonthlyGoalType.minutes => l10n.monthlyMinutes,
                    MonthlyGoalType.pages => l10n.monthlyPages,
                    MonthlyGoalType.books => l10n.monthlyBooks,
                  },
                ),
              ),
            const SizedBox(height: 8),
            Text(
              l10n.monthlyGoalSuggestions,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Wrap(
              spacing: 6,
              children: [
                for (final value in [300, 600, 1000, 1500])
                  ActionChip(
                    label: Text('$value'),
                    onPressed: () => setState(
                      () => _controllers[MonthlyGoalType.minutes]!.text =
                          '$value',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final targets = <MonthlyGoalType, int>{};
            for (final type in _selected) {
              final value = int.tryParse(_controllers[type]!.text);
              if (value == null || value <= 0) return;
              targets[type] = value;
            }
            Navigator.of(context).pop(MonthlyGoal(targets));
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _CustomGoalDialog extends StatefulWidget {
  final int initialMinutes;

  const _CustomGoalDialog({required this.initialMinutes});

  @override
  State<_CustomGoalDialog> createState() => _CustomGoalDialogState();
}

class _CustomGoalDialogState extends State<_CustomGoalDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialMinutes}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final minutes = int.tryParse(_controller.text.trim());
    if (minutes == null || !AppConstants.isValidDailyGoal(minutes)) {
      setState(() {
        _error = l10n.customGoalInvalid(
          AppConstants.minDailyGoalMinutes,
          AppConstants.maxDailyGoalMinutes,
        );
      });
      return;
    }
    Navigator.of(context).pop(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.customGoalTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.customGoalHint,
          errorText: _error,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
