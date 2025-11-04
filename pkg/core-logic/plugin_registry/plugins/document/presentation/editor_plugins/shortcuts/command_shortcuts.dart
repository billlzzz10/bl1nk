import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/align_toolbar_item/custom_text_align_command.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/math_equation/math_equation_shortcut.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/shortcuts/custom_delete_command.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/undo_redo/custom_undo_redo_commands.dart';
import '../../../../../../../../appflowy/workspace/presentation/settings/widgets/emoji_picker/emoji_picker.dart';
import '../../../../../../../../appflowy_editor/appflowy_editor.dart';
import '../../../../../../../../appflowy_editor_plugins/appflowy_editor_plugins.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';

import 'exit_edit_mode_command.dart';

final List<CommandShortcutEvent> defaultCommandShortcutEvents = [
  ...commandShortcutEvents.map((e) => e.copyWith()),
];

// Command shortcuts are order-sensitive. Verify order when modifying.
List<CommandShortcutEvent> commandShortcutEvents = [
  ...simpleTableCommands,

  customExitEditingCommand,
  backspaceToTitle,
  removeToggleHeadingStyle,

  arrowUpToTitle,
  arrowLeftToTitle,

  toggleToggleListCommand,

  ...localizedCodeBlockCommands,

  customCopyCommand,
  customPasteCommand,
  customPastePlainTextCommand,
  customCutCommand,
  customUndoCommand,
  customRedoCommand,

  ...customTextAlignCommands,

  customDeleteCommand,
  insertInlineMathEquationCommand,

  // remove standard shortcuts for copy, cut, paste, todo
  ...standardCommandShortcutEvents
    ..removeWhere(
      (shortcut) => [
        copyCommand,
        cutCommand,
        pasteCommand,
        pasteTextWithoutFormattingCommand,
        toggleTodoListCommand,
        undoCommand,
        redoCommand,
        exitEditingCommand,
        ...tableCommands,
        deleteCommand,
      ].contains(shortcut),
    ),

  emojiShortcutEvent,
];

final _codeBlockLocalization = CodeBlockLocalizations(
  codeBlockNewParagraph:
      LocaleKeys.settings_shortcutsPage_commands_codeBlockNewParagraph.tr(),
  codeBlockIndentLines:
      LocaleKeys.settings_shortcutsPage_commands_codeBlockIndentLines.tr(),
  codeBlockOutdentLines:
      LocaleKeys.settings_shortcutsPage_commands_codeBlockOutdentLines.tr(),
  codeBlockSelectAll:
      LocaleKeys.settings_shortcutsPage_commands_codeBlockSelectAll.tr(),
  codeBlockPasteText:
      LocaleKeys.settings_shortcutsPage_commands_codeBlockPasteText.tr(),
  codeBlockAddTwoSpaces:
      LocaleKeys.settings_shortcutsPage_commands_codeBlockAddTwoSpaces.tr(),
);

final localizedCodeBlockCommands = codeBlockCommands(
  localizations: _codeBlockLocalization,
);
