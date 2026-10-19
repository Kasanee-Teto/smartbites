// Owner: Louis | FR: FR-01
// Design: stitch_smartbites_meal_budget_planner/smartbites_welcome_onboarding/code.html

import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const WelcomeScreen({
    super.key,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Louis): Implement welcome illustration, value proposition, and start button in Step 5.
    return const Scaffold(
      body: Center(
        child: Text('WelcomeScreen - Louis (Selamat Datang)'),
      ),
    );
  }
}
