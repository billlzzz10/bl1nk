import 'package:flutter/material.dart';

// Placeholder share button while AppFlowy dependencies are decoupled

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.view,
    this.onPressed,
  });

  final dynamic view;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      tooltip: 'Share (Coming soon)',
      onPressed: onPressed ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share functionality coming soon'),
          ),
        );
      },
    );
  }
}