import '../../../../flutter/material.dart';

// Feature flag to toggle Share UI while decoupling proceeds.
// Enable via: --dart-define=ENABLE_SHARE_UI=true
const bool kEnableShareUi = bool.fromEnvironment(
  'ENABLE_SHARE_UI',
  defaultValue: false,
);

/// ShareMenuButton (temporary)
/// TODO(P0): Restore full Share menu (filled button + popover, actions: Share/Export/Publish)
/// Relates-to: #7 (decouple AppFlowy). If no tracking issue exists, create one: "Restore ShareMenuButton".
class ShareMenuButton extends StatelessWidget {
  const ShareMenuButton({super.key, this.tabs = const []});
  final List<dynamic> tabs; // kept for API compatibility

  @override
  Widget build(BuildContext context) {
    if (kEnableShareUi) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          // Temporary no-op; surface feedback to avoid confusion
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$value: Coming soon')),
          );
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'Share', child: Text('Share')),
          PopupMenuItem(value: 'Export', child: Text('Export')),
          PopupMenuItem(value: 'Publish', child: Text('Publish')),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: FilledButton.icon(
            onPressed: null, // handled by PopupMenuButton
            icon: Icon(Icons.ios_share),
            label: Text('Share'),
          ),
        ),
      );
    }

    // Default: show disabled button to preserve layout and inform users
    return const Tooltip(
      message: 'Coming soon',
      child: FilledButton.icon(
        onPressed: null, // disabled
        icon: Icon(Icons.ios_share),
        label: Text('Share'),
      ),
    );
  }
}
