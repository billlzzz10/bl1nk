import 'dart:async';

import '../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../appflowy/plugins/document/application/document_data_pb_extension.dart';
import '../../../../../appflowy/plugins/document/application/prelude.dart';
import '../../../../../appflowy/shared/markdown_to_document.dart';
import '../../../../../appflowy/workspace/application/view/view_service.dart';
import '../../../../../appflowy_backend/log.dart';
import '../../../../../appflowy_backend/protobuf/flowy-folder/protobuf.dart';
import '../../../../../appflowy_editor/appflowy_editor.dart';
import '../../../../../appflowy_result/appflowy_result.dart';
import '../../../../../easy_localization/easy_localization.dart';
import '../../../../../flutter/foundation.dart';
import '../../../../../flutter_chat_core/flutter_chat_core.dart';

class ChatEditDocumentService {
  const ChatEditDocumentService._();

  static Future<ViewPB?> saveMessagesToNewPage(
    String chatPageName,
    String parentViewId,
    List<TextMessage> messages,
  ) async {
    if (messages.isEmpty) {
      return null;
    }

    // Convert messages to markdown and trim the last empty newline.
    final completeMessage = messages.map((m) => m.text).join('\n').trimRight();
    if (completeMessage.isEmpty) {
      return null;
    }

    final document = customMarkdownToDocument(
      completeMessage,
      tableWidth: 250.0,
    );
    final initialBytes =
        DocumentDataPBFromTo.fromDocument(document)?.writeToBuffer();
    if (initialBytes == null) {
      Log.error('Failed to convert messages to document');
      return null;
    }

    return ViewBackendService.createView(
      name: LocaleKeys.chat_addToNewPageName.tr(args: [chatPageName]),
      layoutType: ViewLayoutPB.Document,
      parentViewId: parentViewId,
      initialDataBytes: initialBytes,
    ).toNullable();
  }

  static Future<void> addMessagesToPage(
    String documentId,
    List<TextMessage> messages,
  ) async {
    // Convert messages to markdown and trim the last empty newline.
    final completeMessage = messages.map((m) => m.text).join('\n').trimRight();
    if (completeMessage.isEmpty) {
      return;
    }

    final bloc = DocumentBloc(
      documentId: documentId,
      saveToBlocMap: false,
    )..add(const DocumentEvent.initial());

    if (bloc.state.editorState == null) {
      await bloc.stream.firstWhere((state) => state.editorState != null);
    }

    final editorState = bloc.state.editorState;
    if (editorState == null) {
      Log.error("Can't get EditorState of document");
      return;
    }

    final messageDocument = customMarkdownToDocument(
      completeMessage,
      tableWidth: 250.0,
    );
    if (messageDocument.isEmpty) {
      Log.error('Failed to convert message to document');
      return;
    }

    final lastNodeOrNull = editorState.document.root.children.lastOrNull;

    final rootIsEmpty = lastNodeOrNull == null;
    final isLastLineEmpty = lastNodeOrNull?.children.isNotEmpty == false &&
        lastNodeOrNull?.delta?.isNotEmpty == false;

    final nodes = [
      if (rootIsEmpty || !isLastLineEmpty) paragraphNode(),
      ...messageDocument.root.children,
      paragraphNode(),
    ];
    final insertPath = rootIsEmpty ||
            listEquals(lastNodeOrNull.path, const [0]) && isLastLineEmpty
        ? const [0]
        : lastNodeOrNull.path.next;

    final transaction = editorState.transaction..insertNodes(insertPath, nodes);
    await editorState.apply(transaction);
    await bloc.close();
  }
}
