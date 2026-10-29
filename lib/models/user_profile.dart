// Owner: Edbert | FR: FR-26, FR-27, FR-28

class UserProfile {
  const UserProfile({
    required this.weeklyBudget,
    required this.waterTargetMl,
    required this.allergies,
    required this.preferences,
    this.darkMode = false,
  });
  final int weeklyBudget;
  final int waterTargetMl;
  final List<String> allergies;
  final List<String> preferences;
  final bool darkMode;

  UserProfile copyWith({
    int? weeklyBudget,
    int? waterTargetMl,
    List<String>? allergies,
    List<String>? preferences,
    bool? darkMode,
  }) {
    return UserProfile(
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      waterTargetMl: waterTargetMl ?? this.waterTargetMl,
      allergies: allergies ?? this.allergies,
      preferences: preferences ?? this.preferences,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
