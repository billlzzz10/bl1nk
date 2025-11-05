import '../../../../flutter/material.dart';

/// Placeholder ShareMenuButton while AppFlowy UI is decoupled.
class ShareMenuButton extends StatelessWidget {
  const ShareMenuButton({super.key, this.tabs = const []});
  final List<dynamic> tabs;

  @override
  Widget build(BuildContext context) {
    // Render nothing for now; to be implemented with desktop UI phase
    return const SizedBox.shrink();
  }
}
