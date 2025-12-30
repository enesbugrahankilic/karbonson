import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../core/navigation/app_router.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.home,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      onPressed: () {
        if (kDebugMode) {
          debugPrint('HomeButton pressed - navigating to home');
        }
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      },
      tooltip: 'Ana Sayfa',
    );
  }
}
