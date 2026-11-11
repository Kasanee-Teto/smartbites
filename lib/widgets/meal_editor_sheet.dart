// Owner: Jessica | Date, time, portion, and diary status editor.

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/widgets/list_tile_spacing.dart';
import 'package:flutter/material.dart';

class MealEditorSheet extends StatefulWidget {
  const MealEditorSheet({
    required this.meals,
    required this.date,
    this.entry,
    this.initialMeal,
    this.initialServings = 1,
    this.initialEaten = false,
    this.initialTime,
    this.allergies = const [],
    super.key,
  });
  final List<Meal> meals;
  final DateTime date;
  final PlannedMeal? entry;
  final Meal? initialMeal;
  final double initialServings;
  final bool initialEaten;
  final TimeOfDay? initialTime;
  final List<String> allergies;

  @override
  State<MealEditorSheet> createState() => _MealEditorSheetState();
}

class _MealEditorSheetState extends State<MealEditorSheet> {
  final _form = GlobalKey<FormState>();
  late String _mealId;
  late DateTime _date;
  late TimeOfDay _time;
  late bool _eaten;
  late final TextEditingController _servings;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _mealId =
        widget.entry?.mealId ?? widget.initialMeal?.id ?? widget.meals.first.id;
    _date = calendarDay(widget.entry?.scheduledAt ?? widget.date);
    _time = widget.entry == null
        ? widget.initialTime ?? const TimeOfDay(hour: 12, minute: 0)
        : TimeOfDay.fromDateTime(widget.entry!.scheduledAt);
    _eaten = widget.entry?.isEaten ?? widget.initialEaten;
    _servings = TextEditingController(
      text: nutrientNumber(widget.entry?.servings ?? widget.initialServings),
    );
  }

  @override
  void dispose() {
    _servings.dispose();
    super.dispose();
  }

  Future<void> _datePicker() {
    return showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Tanggal makan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    ).then((date) {
      if (date != null && mounted) {
        setState(() {
          _date = date;
          _dateError = null;
        });
      }
    });
  }

  Future<void> _timePicker() {
    return showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Waktu makan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    ).then((time) {
      if (time != null && mounted) setState(() => _time = time);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meals.firstWhere((m) => m.id == _mealId);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _form,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                widget.entry == null ? 'Jadwalkan menu' : 'Ubah jadwal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _mealId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Menu makan'),
                items: [
                  for (final m in widget.meals)
                    DropdownMenuItem(
                      value: m.id,
                      child: Text(
                        m.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) {
                    setState(() {
                      if (_mealId != id) _eaten = false;
                      _mealId = id;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              if (matchesAllergy(meal, widget.allergies))
                Text(
                  'Perhatian: menu memuat alergen dalam profil Anda',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Text('${meal.source.label} • ${meal.category}'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _datePicker,
                icon: const Icon(Icons.calendar_month),
                label: Text(mealDateLabel(_date)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _timePicker,
                icon: const Icon(Icons.schedule),
                label: Text(
                  '${_time.hour.toString().padLeft(2, '0')}.'
                  '${_time.minute.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _servings,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Jumlah porsi',
                  helperText: '0,25 sampai 10 porsi',
                ),
                validator: (text) {
                  final value = double.tryParse(
                    (text ?? '').replaceAll(',', '.'),
                  );
                  if (value == null ||
                      !value.isFinite ||
                      value < 0.25 ||
                      value > 10) {
                    return 'Masukkan 0,25 sampai 10 porsi';
                  }
                  return null;
                },
              ),
              ListTileSpacing(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sudah dimakan'),
                  value: _eaten,
                  onChanged: (value) => setState(() => _eaten = value ?? false),
                ),
              ),
              if (_dateError != null)
                Text(
                  _dateError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  if (_eaten && _date.isAfter(calendarDay(DateTime.now()))) {
                    setState(
                      () => _dateError =
                          'Tanggal mendatang belum bisa dicatat dimakan',
                    );
                    return;
                  }
                  Navigator.of(context).pop(
                    PlannedMeal(
                      id:
                          widget.entry?.id ??
                          'meal_${DateTime.now().microsecondsSinceEpoch}',
                      mealId: _mealId,
                      scheduledAt: DateTime(
                        _date.year,
                        _date.month,
                        _date.day,
                        _time.hour,
                        _time.minute,
                      ),
                      servings: double.parse(
                        _servings.text.replaceAll(',', '.'),
                      ),
                      isEaten: _eaten,
                    ),
                  );
                },
                child: const Text('Simpan menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
