import '../../../../../../../appflowy/plugins/document/presentation/editor_plugins/mention/mention_page_block.dart';
import '../../../../../../../appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import '../../../../../../../appflowy_editor/appflowy_editor.dart';

class SubPageNodeParser extends NodeParser {
  const SubPageNodeParser();

  @override
  String get id => SubPageBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final String viewId = node.attributes[SubPageBlockKeys.viewId] ?? '';
    if (viewId.isNotEmpty) {
      final view = pageMemorizer[viewId];
      return '[$viewId](${view?.name ?? ''})\n';
    }
    return '';
  }
}
