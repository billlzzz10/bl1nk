import '../../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../../../flutter/material.dart';

class CloseKeyboardOrMenuButton extends StatelessWidget {
  const CloseKeyboardOrMenuButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 42,
      child: FlowyButton(
        text: const FlowySvg(
          FlowySvgs.m_toolbar_keyboard_m,
        ),
        onTap: onPressed,
      ),
    );
  }
}
