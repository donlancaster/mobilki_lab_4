import 'package:flutter/material.dart';

import '../colors.dart';
import '../dimens.dart';

class CustomActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const CustomActionButton({
    Key? key,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimens.appBarButtonHeight,
        width: AppDimens.appBarButtonHeight,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: AppColors.button,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
