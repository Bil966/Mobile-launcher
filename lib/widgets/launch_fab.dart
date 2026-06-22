import 'package:flutter/material.dart';

class LaunchFab extends StatelessWidget {
  const LaunchFab({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.play_arrow),
      label: const Text('Chơi'),
    );
  }
}
