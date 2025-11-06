import 'dart:io';

import 'package:path/path.dart' as path;

const errorMessageTextKey = "errorMessageText";
const systemUserId = "system";
const aiResponseUserId = "0";

/// `messageRefSourceJsonStringKey` is the key used for metadata that contains the reference
/// source of a message. Each message may include this information.
/// - When used in a sent message, it indicates that the message includes an attachment.
/// - When used in a received message, it indicates the AI reference sources used to answer a question.
const messageRefSourceJsonStringKey = "ref_source_json_string";
const messageChatFileListKey = "chat_files";
const messageQuestionIdKey = "question_id";

class ChatMessageRefSource {
  ChatMessageRefSource({
    required this.id,
    required this.name,
    required this.source,
  });

  factory ChatMessageRefSource.fromJson(Map<String, dynamic> json) {
    return ChatMessageRefSource(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String source;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'source': source,
      };
}

class AIChatProgress {
  AIChatProgress({
    required this.step,
  });

  factory AIChatProgress.fromJson(Map<String, dynamic> json) {
    return AIChatProgress(step: json['step']?.toString() ?? '');
  }

  final String step;

  Map<String, dynamic> toJson() => {'step': step};
}

enum PromptResponseState {
  ready,
  sendingQuestion,
  streamingAnswer,
  relatedQuestionsReady;

  bool get isReady => this == ready || this == relatedQuestionsReady;
}

enum ContextLoaderType {
  pdf,
  txt,
  markdown,
  unknown,
}

class ChatFile {
  const ChatFile({
    required this.filePath,
    required this.fileName,
    required this.fileType,
  });

  static ChatFile? fromFilePath(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return null;
    }

    final fileName = path.basename(filePath);
    final extension = path.extension(filePath).toLowerCase();

    ContextLoaderType fileType;
    switch (extension) {
      case '.pdf':
        fileType = ContextLoaderType.pdf;
        break;
      case '.txt':
        fileType = ContextLoaderType.txt;
        break;
      case '.md':
        fileType = ContextLoaderType.markdown;
        break;
      default:
        fileType = ContextLoaderType.unknown;
    }

    return ChatFile(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
    );
  }

  final String filePath;
  final String fileName;
  final ContextLoaderType fileType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatFile && other.filePath == filePath;

  @override
  int get hashCode => filePath.hashCode;
}

class ChatViewReference {
  const ChatViewReference({
    required this.id,
    required this.name,
    this.isDocumentView = false,
  });

  final String id;
  final String name;
  final bool isDocumentView;
}

typedef ChatFileMap = Map<String, ChatFile>;
typedef ChatMentionedPageMap = Map<String, ChatViewReference>;

class ChatLoadingState {
  const ChatLoadingState._({required this.isLoading, this.error});

  const ChatLoadingState.loading() : this._(isLoading: true);

  const ChatLoadingState.finish({String? error})
      : this._(isLoading: false, error: error);

  final bool isLoading;
  final String? error;

  bool get isFinish => !isLoading;
}

enum OnetimeShotType {
  sendingMessage,
  relatedQuestion,
  error,
}

const onetimeShotType = "OnetimeShotType";

OnetimeShotType? onetimeMessageTypeFromMeta(Map<String, dynamic>? metadata) {
  final value = metadata?[onetimeShotType];
  if (value == null) return null;
  if (value is OnetimeShotType) return value;
  if (value is String) {
    try {
      return OnetimeShotType.values.firstWhere(
        (e) => e.toString().split('.').last == value,
      );
    } catch (_) {
      return null;
    }
  }
  return null;
}

enum LoadChatMessageStatus {
  loading,
  loadingRemote,
  ready,
}
