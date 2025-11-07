// Placeholder name generator while AppFlowy dependencies are decoupled

class PublishNameGenerator {
  static String generate({String? baseName}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final base = baseName ?? 'document';
    return '${base}_$timestamp';
  }
  
  static String sanitize(String name) {
    // Remove special characters and spaces
    return name.replaceAll(RegExp(r'[^\w\s-]'), '')
               .replaceAll(RegExp(r'\s+'), '-')
               .toLowerCase();
  }
}