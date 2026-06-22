class ModEntry {
  const ModEntry({
    required this.name,
    required this.isEnabled,
    required this.filePath,
  });

  final String name;
  final bool isEnabled;
  final String filePath;
}
