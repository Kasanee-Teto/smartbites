// Owner: Jessica | Personal goals, no automatically prescribed limits.

import 'package:budget_bites/utils/meal_planning.dart';
import 'package:flutter/material.dart';

class NutritionGoalsSheet extends StatefulWidget {
  const NutritionGoalsSheet({required this.goals, super.key});
  final Map<Nutrient, double> goals;

  @override
  State<NutritionGoalsSheet> createState() => _NutritionGoalsSheetState();
}

class _NutritionGoalsSheetState extends State<NutritionGoalsSheet> {
  final _form = GlobalKey<FormState>();
  late final Map<Nutrient, TextEditingController> _controllers = {
    for (final n in Nutrient.values)
      n: TextEditingController(text: widget.goals[n]?.toString() ?? ''),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(right: 20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Target & batas harian',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              for (final n in Nutrient.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _controllers[n],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: '${n.isLimit ? 'Batas' : 'Target'} ${n.label}',
                      suffixText: n.unit,
                    ),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) return null;
                      final value = double.tryParse(text.replaceAll(',', '.'));
                      if (value == null ||
                          !value.isFinite ||
                          value <= 0 ||
                          value > 1000000) {
                        return 'Masukkan angka lebih dari 0, maksimal 1.000.000';
                      }
                      return null;
                    },
                  ),
                ),
              FilledButton(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  Navigator.of(context).pop(<Nutrient, double>{
                    for (final entry in _controllers.entries)
                      if (entry.value.text.trim().isNotEmpty)
                        entry.key: double.parse(
                          entry.value.text.replaceAll(',', '.'),
                        ),
                  });
                },
                child: const Text('Simpan target'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
