import 'dart:convert';

import '../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../appflowy/plugins/document/presentation/editor_plugins/copy_and_paste/clipboard_service.dart';
import '../../../../../../../appflowy/startup/startup.dart';
import '../../../../../../../appflowy/workspace/presentation/widgets/dialogs.dart';
import '../../../../../../../appflowy_editor/appflowy_editor.dart';
import '../../../../../../../appflowy_editor_plugins/appflowy_editor_plugins.dart';
import '../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../flowy_infra/theme_extension.dart';
import '../../../../../../../flowy_infra_ui/style_widget/icon_button.dart';
import '../../../../../../../flowy_infra_ui/widget/flowy_tooltip.dart';
import '../../../../../../../flutter/material.dart';

CodeBlockCopyBuilder codeBlockCopyBuilder =
    (_, node) => _CopyButton(node: node);

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.node});

  final Node node;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FlowyTooltip(
        message: LocaleKeys.document_codeBlock_copyTooltip.tr(),
        child: FlowyIconButton(
          onPressed: () async {
            final delta = node.delta;
            if (delta == null) {
              return;
            }

            final document = Document.blank()
              ..insert([0], [node.deepCopy()])
              ..toJson();

            await getIt<ClipboardService>().setData(
              ClipboardServiceData(
                plainText: delta.toPlainText(),
                inAppJson: jsonEncode(document.toJson()),
              ),
            );

            if (context.mounted) {
              showToastNotification(
                message: LocaleKeys.document_codeBlock_codeCopiedSnackbar.tr(),
              );
            }
          },
          hoverColor: Theme.of(context).colorScheme.secondaryContainer,
          icon: FlowySvg(
            FlowySvgs.copy_s,
            color: AFThemeExtension.of(context).textColor,
          ),
        ),
      ),
    );
  }
}
