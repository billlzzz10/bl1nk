import 'package:flutter/material.dart';

// Placeholder enums and classes while AppFlowy dependencies are decoupled

enum ShareMenuTab {
  share,
  publish,
  exportAs;

  String get i18n {
    switch (this) {
      case ShareMenuTab.share:
        return 'Share';
      case ShareMenuTab.publish:
        return 'Publish';
      case ShareMenuTab.exportAs:
        return 'Export As';
    }
  }
}

class ShareMenu extends StatefulWidget {
  const ShareMenu({
    super.key,
    required this.tabs,
    required this.viewName,
    required this.onClose,
  });

class ShareMenu extends StatelessWidget {
  const ShareMenu({super.key, required this.tabs, required this.viewName, required this.onClose});
  final List<ShareMenuTab> tabs;
  final String viewName;
  final VoidCallback onClose;

  @override
  State<ShareMenu> createState() => _ShareMenuState();
}

class _ShareMenuState extends State<ShareMenu> {
  @override
  Widget build(BuildContext context) {
    // Placeholder implementation
    return Center(
      child: Text('Share Menu: ${widget.viewName} (Coming soon)'),
    );
  }
}