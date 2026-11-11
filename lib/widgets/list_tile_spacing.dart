import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/widgets.dart';

class ListTileSpacing extends Padding {
  const ListTileSpacing({required Widget super.child, super.key})
    : super(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceXs / 2),
      );
}
