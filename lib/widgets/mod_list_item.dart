import 'package:flutter/material.dart';
import 'package:geode_mod_manager/models/mod_entry.dart';

class ModListItem extends StatelessWidget {
  const ModListItem({
    super.key,
    required this.mod,
    required this.onToggle,
    this.busy = false,
  });

  final ModEntry mod;
  final ValueChanged<bool> onToggle;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          mod.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          mod.isEnabled ? 'Đang bật' : 'Đã tắt',
          style: theme.textTheme.bodySmall?.copyWith(
            color: mod.isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Switch(
          value: mod.isEnabled,
          onChanged: busy ? null : onToggle,
        ),
      ),
    );
  }
}
