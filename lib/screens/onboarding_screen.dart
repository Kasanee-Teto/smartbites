// Owner: Louis | FR: FR-01
// Design: stitch_smartbites_meal_budget_planner/smartbites_welcome_onboarding/code.html

import 'package:budget_bites/models/user_profile.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final ValueChanged<UserProfile>? onFinish;

  const OnboardingScreen({
    super.key,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Louis): Implement 3-step setup (Budget slider, Allergies chip selection, Diet preferences) in Step 5.
    return const Scaffold(
      body: Center(
        child: Text('OnboardingScreen - Louis (Orientasi Awal)'),
      ),
    );
  }
}
