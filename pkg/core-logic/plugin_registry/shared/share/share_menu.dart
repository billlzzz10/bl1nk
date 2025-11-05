import '../../../../flutter/material.dart';

enum ShareMenuTab { share, publish, exportAs }

class ShareMenu extends StatelessWidget {
  const ShareMenu({super.key, required this.tabs, required this.viewName, required this.onClose});
  final List<ShareMenuTab> tabs;
  final String viewName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // Placeholder UI until desktop share menu is implemented
    return const SizedBox.shrink();
  }
}
