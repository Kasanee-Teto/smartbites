// Owner: Edbert | FR: FR-26, FR-27, FR-28
// Design: stitch_smartbites_meal_budget_planner/smartbites_profil_pencapaian/code.html

import 'package:budget_bites/models/user_profile.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // TODO(Edbert): Implement profile editing, allergy checklist, dark mode toggle, and reset action.
    return const Scaffold(
      body: Center(
        child: Text('ProfileScreen - Edbert (Profil)'),
      ),
    );
  }
}
