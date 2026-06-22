import 'package:flutter/material.dart';

class ImportModButton extends StatelessWidget {
  const ImportModButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.file_upload_outlined),
      tooltip: 'Import mod',
      onPressed: onPressed,
    );
  }
}
