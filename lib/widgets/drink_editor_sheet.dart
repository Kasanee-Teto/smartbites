import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/widgets/drink_category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrinkEditorSheet extends StatefulWidget {
  const DrinkEditorSheet({super.key, this.record});

  final WaterRecord? record;

  @override
  State<DrinkEditorSheet> createState() => _DrinkEditorSheetState();
}

class _DrinkEditorSheetState extends State<DrinkEditorSheet> {
  final _form = GlobalKey<FormState>();
  late DrinkCategory _category = widget.record?.category ?? DrinkCategory.water;
  late final TextEditingController _volume = TextEditingController(
    text: '${widget.record?.amountMl ?? _category.defaultMl}',
  );

  @override
  void dispose() {
    _volume.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(context, (
      category: _category,
      volume: int.parse(_volume.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 4, 24, bottom + 24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.record == null ? 'Catat minuman' : 'Ubah catatan minum',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DrinkCategory>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Jenis minuman'),
                items: [
                  for (final category in DrinkCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            category.icon,
                            color: category.color(theme.colorScheme),
                          ),
                          const SizedBox(width: 8),
                          Flexible(child: Text(category.label)),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;
                    if (widget.record == null) {
                      _volume.text = '${value.defaultMl}';
                    }
                  });
                },
              ),
              if (_category.creditPercent < 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Minuman ini mengurangi skor hidrasi aplikasi',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final volume in [100, 200, 250, 330, 500])
                    ChoiceChip(
                      label: Text('$volume ml'),
                      selected: _volume.text == '$volume',
                      onSelected: (_) =>
                          setState(() => _volume.text = '$volume'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _volume,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Volume',
                  suffixText: 'ml',
                ),
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _save(),
                validator: (value) {
                  final volume = int.tryParse(value ?? '');
                  if (volume == null || volume < 1 || volume > 10000) {
                    return 'Masukkan volume 1-10.000 ml';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: const Text('Simpan catatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
