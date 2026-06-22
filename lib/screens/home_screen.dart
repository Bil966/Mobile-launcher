import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geode_mod_manager/models/mod_entry.dart';
import 'package:geode_mod_manager/services/game_launcher_service.dart';
import 'package:geode_mod_manager/services/mod_file_service.dart';
import 'package:geode_mod_manager/services/permission_service.dart';
import 'package:geode_mod_manager/widgets/import_mod_button.dart';
import 'package:geode_mod_manager/widgets/launch_fab.dart';
import 'package:geode_mod_manager/widgets/mod_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _permissionService = PermissionService();
  final _modService = ModFileService();
  final _launcherService = GameLauncherService();

  List<ModEntry> _mods = [];
  bool _loading = true;
  bool _permissionGranted = false;
  bool _launching = false;
  bool _importing = false;
  String? _busyModName;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    _permissionGranted = await _permissionService.requestStorageAccess();
    if (_permissionGranted) {
      await _refreshMods();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshMods() async {
    try {
      final mods = await _modService.loadMods();
      if (mounted) setState(() => _mods = mods);
    } catch (e) {
      _showSnack('Không thể đọc danh sách mod: $e');
    }
  }

  Future<void> _importMod() async {
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['geode', 'dll', 'dylib'],
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return;

      var imported = 0;
      final errors = <String>[];

      for (final file in result.files) {
        try {
          await _modService.importMod(file);
          imported++;
        } catch (e) {
          errors.add('${file.name}: $e');
        }
      }

      await _refreshMods();

      if (imported > 0) {
        _showSnack('Đã import $imported mod.');
      }
      if (errors.isNotEmpty) {
        _showSnack(errors.first);
      }
    } catch (e) {
      _showSnack('Import thất bại: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _toggleMod(ModEntry mod, bool enabled) async {
    setState(() => _busyModName = mod.name);
    try {
      await _modService.setModEnabled(mod, enabled);
      await _refreshMods();
    } catch (e) {
      _showSnack('Không thể ${enabled ? 'bật' : 'tắt'} mod: $e');
    } finally {
      if (mounted) setState(() => _busyModName = null);
    }
  }

  Future<void> _launchGame() async {
    setState(() => _launching = true);
    try {
      final installed = await _launcherService.isGameInstalled();
      if (!installed) {
        _showSnack('Geometry Dash chưa được cài đặt.');
        return;
      }
      await _launcherService.launchGame();
    } catch (e) {
      _showSnack('Không thể khởi chạy game: $e');
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geode Mod Manager'),
        actions: [
          ImportModButton(
            loading: _importing,
            onPressed: _permissionGranted && !_loading ? _importMod : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loading ? null : _init,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: LaunchFab(
        loading: _launching,
        onPressed: _permissionGranted ? _launchGame : null,
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_permissionGranted) {
      return _MessageView(
        icon: Icons.folder_off_outlined,
        title: 'Cần quyền truy cập file',
        subtitle:
            'Bật "Allow management of all files" trong Cài đặt để quản lý mod.',
        actionLabel: 'Mở Cài đặt',
        onAction: _init,
      );
    }

    if (_mods.isEmpty) {
      return _MessageView(
        icon: Icons.extension_off_outlined,
        title: 'Không có mod nào',
        subtitle:
            'Import file .geode hoặc cài Geode loader trong Geometry Dash.',
        actionLabel: 'Import mod',
        onAction: _importMod,
        secondaryActionLabel: 'Làm mới',
        onSecondaryAction: _refreshMods,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMods,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _mods.length,
        itemBuilder: (context, index) {
          final mod = _mods[index];
          return ModListItem(
            mod: mod,
            busy: _busyModName == mod.name,
            onToggle: (value) => _toggleMod(mod, value),
          );
        },
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
