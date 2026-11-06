// Owner: Edbert | FR: FR-24, FR-25

import 'package:budget_bites/models/waste_record.dart';
import 'package:budget_bites/utils/app_colors.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:flutter/material.dart';

class WasteItemTile extends StatelessWidget {
  final WasteRecord record;
  final ValueChanged<String>? onDelete;

  const WasteItemTile({
    super.key,
    required this.record,
    this.onDelete,
  });

  String get _subtitle {
    final parts = <String>[
      record.portion,
      if (record.reason.isNotEmpty) record.reason,
      '${record.date.day}/${record.date.month}',
    ];
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delete = onDelete;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.alertTerracotta.withAlpha(30),
        child: const Icon(
          Icons.no_food_outlined,
          color: AppColors.alertTerracotta,
        ),
      ),
      title: Text(record.itemName),
      subtitle: Text(_subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatRupiah(record.estimatedLoss),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.alertTerracotta,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (delete != null)
            IconButton(
              tooltip: 'Hapus catatan',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => delete(record.id),
            ),
        ],
      ),
    );
  }
}