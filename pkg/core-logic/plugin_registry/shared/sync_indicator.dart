import '../../../../flutter/material.dart';

/// Placeholder view reference for decoupled build.
class ViewPB {
  const ViewPB({required this.id, this.name = ''});
  final String id;
  final String name;
}

/// Placeholder indicator while AppFlowy sync is decoupled.
class DocumentSyncIndicator extends StatelessWidget {
  const DocumentSyncIndicator({super.key, required this.view});
  final ViewPB view;

  @override
  Widget build(BuildContext context) {
    // No-op indicator for now
    return const SizedBox.shrink();
  }
}

class DatabaseSyncIndicator extends StatelessWidget {
  const DatabaseSyncIndicator({super.key, required this.view});
  final ViewPB view;

  @override
  Widget build(BuildContext context) {
    // No-op indicator for now
    return const SizedBox.shrink();
  }
}
