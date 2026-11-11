import 'dart:async';

import 'package:budget_bites/models/hydration_reminder.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/hydration_notifications.dart';
import 'package:budget_bites/widgets/list_tile_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HydrationSettingsScreen extends StatefulWidget {
  const HydrationSettingsScreen({
    required this.goal,
    required this.settings,
    super.key,
  });

  final int goal;
  final HydrationReminder settings;

  @override
  State<HydrationSettingsScreen> createState() =>
      _HydrationSettingsScreenState();
}

class _HydrationSettingsScreenState extends State<HydrationSettingsScreen> {
  static const _intervals = [30, 60, 120];
  final _form = GlobalKey<FormState>();
  late HydrationReminder _settings = widget.settings;
  late final _goal = TextEditingController(text: '${widget.goal}');
  late final _custom = TextEditingController(
    text: '${_settings.interval.inMinutes}',
  );
  late int _selectedInterval = _intervals.contains(_settings.interval.inMinutes)
      ? _settings.interval.inMinutes
      : 0;
  String? _browserStatus;

  @override
  void dispose() {
    _goal.dispose();
    _custom.dispose();
    super.dispose();
  }

  Future<void> _requestBrowser() async {
    final status = await requestDrinkNotification();
    if (mounted) setState(() => _browserStatus = status);
  }

  Future<void> _pickTime({required bool start}) async {
    final minute = start ? _settings.startMinute : _settings.endMinute;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
    if (!mounted || time == null) return;
    final value = time.hour * 60 + time.minute;
    setState(
      () => _settings = start
          ? _settings.copyWith(startMinute: value)
          : _settings.copyWith(endMinute: value),
    );
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final interval = !_settings.enabled
        ? _settings.interval.inMinutes
        : _selectedInterval == 0
        ? int.parse(_custom.text)
        : _selectedInterval;
    Navigator.pop(context, (
      goal: int.parse(_goal.text),
      settings: _settings.copyWith(interval: Duration(minutes: interval)),
    ));
  }

  String _timeLabel(int value) =>
      TimeOfDay(hour: value ~/ 60, minute: value % 60).format(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget reminderSwitch({
      required String label,
      required bool value,
      required ValueChanged<bool>? onChanged,
      Widget? subtitle,
    }) => ListTileSpacing(
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        tileColor: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(label),
        subtitle: subtitle,
        value: value,
        onChanged: onChanged,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan hidrasi')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Simpan pengaturan'),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Target harian', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _goal,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Target hidrasi',
                        suffixText: 'ml',
                      ),
                      validator: (text) {
                        final value = int.tryParse(text ?? '');
                        if (value == null ||
                            value < AppConstants.minWaterTargetMl ||
                            value > AppConstants.maxWaterTargetMl) {
                          return 'Masukkan target 1.000-4.000 ml';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text('Pengingat minum', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    reminderSwitch(
                      label: 'Aktifkan pengingat',
                      subtitle: const Text(
                        'Pengingat berjalan saat SmartBites terbuka',
                      ),
                      value: _settings.enabled,
                      onChanged: (enabled) {
                        setState(
                          () =>
                              _settings = _settings.copyWith(enabled: enabled),
                        );
                        if (!enabled) return;
                        if (_settings.sound || _settings.alarm) {
                          prepareDrinkSound();
                        }
                        if (_settings.browser && supportsBrowserReminders) {
                          unawaited(_requestBrowser());
                        }
                      },
                    ),
                    if (_settings.enabled) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _pickTime(start: true),
                            icon: const Icon(Icons.schedule),
                            label: Text(
                              'Mulai ${_timeLabel(_settings.startMinute)}',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _pickTime(start: false),
                            icon: const Icon(Icons.bedtime_outlined),
                            label: Text(
                              'Selesai ${_timeLabel(_settings.endMinute)}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedInterval,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Jeda sejak minuman terakhir',
                        ),
                        items: const [
                          DropdownMenuItem(value: 30, child: Text('30 menit')),
                          DropdownMenuItem(value: 60, child: Text('1 jam')),
                          DropdownMenuItem(value: 120, child: Text('2 jam')),
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Jeda kustom'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedInterval = value ?? 60),
                      ),
                      if (_selectedInterval == 0) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _custom,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Jeda kustom',
                            suffixText: 'menit',
                          ),
                          validator: (text) {
                            final value = int.tryParse(text ?? '');
                            if (value == null || value < 1 || value > 1440) {
                              return 'Masukkan jeda 1-1.440 menit';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 8),
                      reminderSwitch(
                        label: 'Mode pintar',
                        subtitle: const Text(
                          'Lewati pengingat setelah target tercapai',
                        ),
                        value: _settings.smart,
                        onChanged: (value) => setState(
                          () => _settings = _settings.copyWith(smart: value),
                        ),
                      ),
                      reminderSwitch(
                        label: 'Notifikasi browser',
                        subtitle: Text(switch (_browserStatus) {
                          'granted' => 'Izin notifikasi diberikan.',
                          'denied' => 'Izin ditolak. Ubah izin di pengaturan situs browser',
                          'unsupported' => 'Notifikasi browser tidak tersedia',
                          _ =>
                            supportsBrowserReminders
                                ? 'Memerlukan izin dari browser'
                                : 'Tersedia di browser yang mendukung',
                        }),
                        value: supportsBrowserReminders && _settings.browser,
                        onChanged: supportsBrowserReminders
                            ? (value) {
                                setState(
                                  () => _settings = _settings.copyWith(
                                    browser: value,
                                  ),
                                );
                                if (value) unawaited(_requestBrowser());
                              }
                            : null,
                      ),
                      reminderSwitch(
                        label: 'Suara dalam aplikasi',
                        value: _settings.sound,
                        onChanged: (value) {
                          if (value) prepareDrinkSound();
                          setState(
                            () => _settings = _settings.copyWith(sound: value),
                          );
                        },
                      ),
                      reminderSwitch(
                        label: 'Nada alarm',
                        value: _settings.alarm,
                        onChanged: (value) {
                          if (value) prepareDrinkSound();
                          setState(
                            () => _settings = _settings.copyWith(alarm: value),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
