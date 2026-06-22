import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:geode_mod_manager/models/mod_entry.dart';

class ModFileService {
  static const _basePath =
      '/storage/emulated/0/Android/data/com.robtopx.geometryjump/files/geode/mods';

  String get enabledDir => _basePath;
  String get disabledDir => '$_basePath/disabled';

  Future<void> ensureDirectories() async {
    await Directory(disabledDir).create(recursive: true);
    await Directory(enabledDir).create(recursive: true);
  }

  Future<bool> geodePathExists() async {
    return Directory('$_basePath/..').exists();
  }

  Future<List<ModEntry>> loadMods() async {
    await ensureDirectories();

    final entries = <ModEntry>[];

    final enabled = Directory(enabledDir);
    if (enabled.existsSync()) {
      for (final entity in enabled.listSync()) {
        if (_isModEntity(entity)) {
          entries.add(ModEntry(
            name: _entityName(entity),
            isEnabled: true,
            filePath: entity.path,
          ));
        }
      }
    }

    final disabled = Directory(disabledDir);
    if (disabled.existsSync()) {
      for (final entity in disabled.listSync()) {
        if (_isModEntity(entity)) {
          entries.add(ModEntry(
            name: _entityName(entity),
            isEnabled: false,
            filePath: entity.path,
          ));
        }
      }
    }

    entries.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return entries;
  }

  String _entityName(FileSystemEntity entity) =>
      entity.path.split(Platform.pathSeparator).last;

  static bool isModFileName(String name) {
    return name.endsWith('.geode') ||
        name.endsWith('.dll') ||
        name.endsWith('.dylib');
  }

  bool _isModEntity(FileSystemEntity entity) {
    final name = _entityName(entity);
    if (name == 'disabled') return false;

    if (entity is Directory) return true;
    if (entity is File) return isModFileName(name);

    return false;
  }

  Future<String> importMod(PlatformFile file, {bool enabled = true}) async {
    await ensureDirectories();

    final fileName = file.name;
    if (!isModFileName(fileName)) {
      throw ArgumentError('Chỉ hỗ trợ file .geode, .dll hoặc .dylib');
    }

    final destinationPath =
        enabled ? '$enabledDir/$fileName' : '$disabledDir/$fileName';

    if (await File(destinationPath).exists() ||
        await Directory(destinationPath).exists()) {
      throw FileSystemException('Mod đã tồn tại', destinationPath);
    }

    if (file.path != null) {
      await File(file.path!).copy(destinationPath);
    } else if (file.bytes != null) {
      await File(destinationPath).writeAsBytes(file.bytes!);
    } else {
      throw FileSystemException('Không thể đọc file mod', fileName);
    }

    return destinationPath;
  }

  Future<int> importMods(List<PlatformFile> files, {bool enabled = true}) async {
    var imported = 0;
    for (final file in files) {
      await importMod(file, enabled: enabled);
      imported++;
    }
    return imported;
  }

  Future<void> setModEnabled(ModEntry mod, bool enabled) async {
    if (mod.isEnabled == enabled) return;

    final fileName = mod.name;
    final destinationPath =
        enabled ? '$enabledDir/$fileName' : '$disabledDir/$fileName';

    if (await File(destinationPath).exists() ||
        await Directory(destinationPath).exists()) {
      throw FileSystemException('File đích đã tồn tại', destinationPath);
    }

    final file = File(mod.filePath);
    if (await file.exists()) {
      await file.rename(destinationPath);
      return;
    }

    final directory = Directory(mod.filePath);
    if (await directory.exists()) {
      await directory.rename(destinationPath);
      return;
    }

    throw FileSystemException('Mod không tồn tại', mod.filePath);
  }
}
