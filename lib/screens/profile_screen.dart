// Owner: Edbert | FR: FR-26, FR-27, FR-28
// Design: stitch_smartbites_meal_budget_planner/smartbites_profil_pencapaian/code.html

import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/meal_preferences_sheet.dart';
import 'package:budget_bites/widgets/option_icon.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.profile,
    super.key,
    this.onUpdateProfile,
    this.onResetData,
    this.onOpenAchievements,
  });

  static const int minBudget = 50000;
  static const int maxBudget = 1000000;
  static const int budgetStep = 10000;

  static const int minWaterMl = 1000;
  static const int maxWaterMl = 4000;
  static const int waterStepMl = 250;

  static const List<String> allergyOptions = [
    'Kacang',
    'Telur',
    'Kedelai',
    'Susu',
    'Seafood',
    'Gluten',
  ];

  static const List<String> preferenceOptions = [
    'Hemat',
    'Tinggi Protein',
    'Vegetarian',
    'Rendah Kalori',
  ];

  final UserProfile profile;
  final ValueChanged<UserProfile>? onUpdateProfile;
  final VoidCallback? onResetData;
  final VoidCallback? onOpenAchievements;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Nilai sementara saat slider digeser. Profil baru dikirim saat jari dilepas
  // supaya satu geseran hanya menghasilkan satu SnackBar "Urungkan".
  late double _budget;
  late double _waterTarget;

  @override
  void initState() {
    super.initState();
    _syncFromProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.profile, widget.profile)) {
      _syncFromProfile();
    }
  }

  void _syncFromProfile() {
    _budget = widget.profile.weeklyBudget
        .clamp(ProfileScreen.minBudget, ProfileScreen.maxBudget)
        .toDouble();
    _waterTarget = widget.profile.waterTargetMl
        .clamp(ProfileScreen.minWaterMl, ProfileScreen.maxWaterMl)
        .toDouble();
  }

  void _update(UserProfile updated) {
    widget.onUpdateProfile?.call(updated);
  }

  Future<void> _editMealPreferences() {
    final profile = widget.profile;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => MealPreferencesSheet(
        allergies: profile.allergies,
        preferences: profile.mealPreferences,
        onSave: (allergies, preferences) {
          _update(
            profile.copyWith(
              allergies: allergies,
              mealPreferences: preferences,
            ),
          );
        },
      ),
    );
  }

  /// Membuat list baru, karena list di profil bisa berupa list const.
  List<String> _toggled(
    List<String> source,
    String value, {
    required bool selected,
  }) {
    final others = source.where((item) => item != value).toList();
    return selected ? [...others, value] : others;
  }

  Future<void> _confirmReset() async {
    final reset = widget.onResetData;
    if (reset == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data demo?'),
        content: const Text(
          'Semua catatan dan pengaturan akan dikembalikan ke data awal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) reset();
  }

  List<Widget> _withGaps(List<Widget> children) {
    return [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(height: AppConstants.spaceMd),
        children[i],
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.profile;

    final budgetPerDay = (_budget / 7).round();
    final waterGlasses = (_waterTarget / 250).round();

    final budgetCard = _SectionCard(
      title: 'Budget Mingguan',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatRupiah(_budget.round()),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Slider(
            value: _budget,
            min: ProfileScreen.minBudget.toDouble(),
            max: ProfileScreen.maxBudget.toDouble(),
            divisions:
                (ProfileScreen.maxBudget - ProfileScreen.minBudget) ~/
                ProfileScreen.budgetStep,
            label: formatRupiah(_budget.round()),
            onChanged: (value) => setState(() => _budget = value),
            onChangeEnd: (value) {
              _update(profile.copyWith(weeklyBudget: value.round()));
            },
          ),
          Text(
            'Rata-rata ${formatRupiah(budgetPerDay)} per hari',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );

    final waterCard = _SectionCard(
      title: 'Target Air Harian',
      icon: Icons.water_drop_outlined,
      iconColor: theme.colorScheme.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_waterTarget.round()} ml',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.tertiary,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.tertiary,
              thumbColor: theme.colorScheme.tertiary,
            ),
            child: Slider(
              value: _waterTarget,
              min: ProfileScreen.minWaterMl.toDouble(),
              max: ProfileScreen.maxWaterMl.toDouble(),
              divisions:
                  (ProfileScreen.maxWaterMl - ProfileScreen.minWaterMl) ~/
                  ProfileScreen.waterStepMl,
              label: '${_waterTarget.round()} ml',
              onChanged: (value) => setState(() => _waterTarget = value),
              onChangeEnd: (value) {
                _update(profile.copyWith(waterTargetMl: value.round()));
              },
            ),
          ),
          Text(
            'Sekitar $waterGlasses gelas (250 ml)',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );

    final allergyCard = _SectionCard(
      title: 'Alergi Makanan',
      icon: Icons.warning_amber_rounded,
      iconColor: theme.colorScheme.error,
      child: _ChipGroup(
        options: ProfileScreen.allergyOptions,
        selected: profile.allergies,
        isAllergy: true,
        onToggle: (value) {
          final isSelected = !profile.allergies.contains(value);
          _update(
            profile.copyWith(
              allergies: _toggled(
                profile.allergies,
                value,
                selected: isSelected,
              ),
            ),
          );
        },
      ),
    );

    final preferenceCard = _SectionCard(
      title: 'Preferensi Makanan',
      icon: Icons.favorite_border,
      child: _ChipGroup(
        options: ProfileScreen.preferenceOptions,
        selected: profile.preferences,
        onToggle: (value) {
          final isSelected = !profile.preferences.contains(value);
          _update(
            profile.copyWith(
              preferences: _toggled(
                profile.preferences,
                value,
                selected: isSelected,
              ),
            ),
          );
        },
      ),
    );

    final mealPrefs = profile.mealPreferences;
    final mealPreferenceCard = _SectionCard(
      title: 'Preferensi Makan',
      icon: Icons.tune,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              OptionIcon(icon: Icons.tune, color: theme.colorScheme.primary),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  'Pilihan makanan: '
                  '${mealPrefs.diet?.label ?? 'Tanpa preferensi'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            'Anggaran per porsi: '
            '${mealPrefs.maxPrice == null ? 'Tanpa batas' : formatRupiah(mealPrefs.maxPrice!)}',
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'Waktu masak: '
            '${mealPrefs.maxCookMinutes == null ? 'Tanpa batas' : '${mealPrefs.maxCookMinutes} menit maksimal'}',
          ),
          const SizedBox(height: AppConstants.spaceMd),
          FilledButton.icon(
            onPressed: widget.onUpdateProfile == null
                ? null
                : _editMealPreferences,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Ubah preferensi makan'),
          ),
        ],
      ),
    );

    final appCard = _SectionCard(
      title: 'Pengaturan Aplikasi',
      icon: Icons.settings_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Pencapaian'),
            subtitle: const Text('Lihat badge dan streak-mu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onOpenAchievements,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mode Gelap'),
            subtitle: const Text('Ganti tampilan terang atau gelap'),
            value: profile.darkMode,
            onChanged: (value) {
              _update(profile.copyWith(darkMode: value));
            },
          ),
          const SizedBox(height: AppConstants.spaceSm),
          OutlinedButton.icon(
            onPressed: widget.onResetData == null ? null : _confirmReset,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset Data Demo'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppConstants.minTouchTarget),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            windowSizeFor(constraints.maxWidth) == WindowSize.compact;

        return SingleChildScrollView(
          // Ruang bawah agar tidak tertutup tombol Catat Cepat.
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            96,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _withGaps([
                        budgetCard,
                        waterCard,
                        allergyCard,
                        preferenceCard,
                        mealPreferenceCard,
                        appCard,
                      ]),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _withGaps([budgetCard, waterCard]),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _withGaps([
                              allergyCard,
                              preferenceCard,
                              mealPreferenceCard,
                              appCard,
                            ]),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? theme.colorScheme.primary),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onToggle,
    this.isAllergy = false,
  });

  final List<String> options;
  final List<String> selected;
  final bool isAllergy;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final selectedColor = isAllergy
        ? colorScheme.errorContainer
        : colorScheme.primary;
    final selectedTextColor = isAllergy
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimary;

    return Wrap(
      spacing: AppConstants.spaceSm,
      runSpacing: AppConstants.spaceSm,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            selectedColor: selectedColor,
            checkmarkColor: selectedTextColor,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected.contains(option)
                  ? selectedTextColor
                  : colorScheme.onSurface,
            ),
            onSelected: (_) => onToggle(option),
          ),
      ],
    );
  }
}
