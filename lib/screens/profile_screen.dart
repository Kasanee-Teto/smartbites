// Owner: Edbert | FR: FR-26, FR-27, FR-28
// Design: stitch_smartbites_meal_budget_planner/smartbites_profil_pencapaian/code.html

import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
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

  const ProfileScreen({
    super.key,
    required this.profile,
    this.onUpdateProfile,
    this.onResetData,
  });

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

  /// Membuat list baru, karena list di profil bisa berupa list const.
  List<String> _toggled(List<String> source, String value, bool selected) {
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

    if (confirmed == true) reset();
  }

  List<Widget> _withGaps(List<Widget> children) {
    return [
      for (int i = 0; i < children.length; i++) ...[
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
            divisions: (ProfileScreen.maxBudget - ProfileScreen.minBudget) ~/
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
              divisions: (ProfileScreen.maxWaterMl - ProfileScreen.minWaterMl) ~/
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
        onChanged: (value, selected) {
          _update(
            profile.copyWith(
              allergies: _toggled(profile.allergies, value, selected),
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
        onChanged: (value, selected) {
          _update(
            profile.copyWith(
              preferences: _toggled(profile.preferences, value, selected),
            ),
          );
        },
      ),
    );

    final appCard = _SectionCard(
      title: 'Pengaturan Aplikasi',
      icon: Icons.settings_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            96.0,
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
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

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
  final List<String> options;
  final List<String> selected;
  final bool isAllergy;
  final void Function(String value, bool selected) onChanged;

  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.isAllergy = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Merah hanya untuk alergi; pilihan lain memakai hijau utama (design.md).
    final selectedColor =
        isAllergy ? colorScheme.errorContainer : colorScheme.primary;
    final selectedTextColor =
        isAllergy ? colorScheme.onErrorContainer : colorScheme.onPrimary;

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
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: selected.contains(option)
                  ? selectedTextColor
                  : colorScheme.onSurface,
            ),
            onSelected: (value) => onChanged(option, value),
          ),
      ],
    );
  }
}