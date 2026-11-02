// Owner: Edbert | FR: FR-26, FR-27, FR-28
// Design: stitch_smartbites_meal_budget_planner/smartbites_profil_pencapaian/code.html

import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/widgets/meal_preferences_sheet.dart';
import 'package:budget_bites/widgets/option_icon.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.profile,
    super.key,
    this.onUpdateProfile,
    this.onResetData,
  });
  final UserProfile profile;
  final ValueChanged<UserProfile>? onUpdateProfile;
  final VoidCallback? onResetData;

  Future<void> _editPreferences(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => MealPreferencesSheet(
          allergies: profile.allergies,
          preferences: profile.mealPreferences,
          onSave: (allergies, preferences) {
            onUpdateProfile?.call(
              profile.copyWith(
                allergies: allergies,
                mealPreferences: preferences,
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preferences = profile.mealPreferences;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        Text('Profil & preferensi', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Atur pilihan makan untuk mencari menu yang sesuai keseharianmu.',
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    OptionIcon(
                      icon: Icons.tune,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Preferensi makan',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Bahan yang dihindari: ${profile.allergies.isEmpty ? 'Belum dipilih' : profile.allergies.join(', ')}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilihan makanan: ${preferences.diet?.label ?? 'Tanpa preferensi'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Anggaran per porsi: ${preferences.maxPrice == null ? 'Tanpa batas' : formatRupiah(preferences.maxPrice!)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Waktu masak: ${preferences.maxCookMinutes == null ? 'Tanpa batas' : '${preferences.maxCookMinutes} menit maksimal'}',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onUpdateProfile == null
                      ? null
                      : () => _editPreferences(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Ubah preferensi makan'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Ringkasan profil', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Anggaran mingguan: ${formatRupiah(profile.weeklyBudget)}'),
        Text('Target air pilihan: ${profile.waterTargetMl} ml'),
        const SizedBox(height: 12),
      ],
    );
  }
}
