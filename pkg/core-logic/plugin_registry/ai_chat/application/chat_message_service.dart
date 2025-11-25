import 'dart:convert';

import 'chat_entity.dart';

const appflowySource = "appflowy";

class ChatMessageMeta {
  const ChatMessageMeta({
    required this.id,
    required this.name,
    required this.data,
    required this.loaderType,
    required this.source,
  });

  final String id;
  final String name;
  final String data;
  final ContextLoaderType loaderType;
  final String source;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageMeta &&
          other.id == id &&
          other.name == name &&
          other.data == data &&
          other.loaderType == loaderType &&
          other.source == source;

  @override
  int get hashCode => Object.hash(id, name, data, loaderType, source);
}

List<ChatFile> fileListFromMessageMetadata(Map<String, dynamic>? map) {
  final List<ChatFile> metadata = [];
  if (map != null) {
    for (final entry in map.entries) {
      if (entry.value is ChatFile) {
        metadata.add(entry.value as ChatFile);
      }
    }
  }

  return metadata;
}

List<ChatFile> chatFilesFromMetadataString(String? s) {
  if (s == null || s.isEmpty || s == "null") {
    return [];
  }

  final metadataJson = jsonDecode(s);
  if (metadataJson is Map<String, dynamic>) {
    final file = chatFileFromMap(metadataJson);
    if (file != null) {
      return [file];
    } else {
      return [];
    }
  } else if (metadataJson is List) {
    return metadataJson
        .map((e) => e as Map<String, dynamic>)
        .map(chatFileFromMap)
        .where((file) => file != null)
        .cast<ChatFile>()
        .toList();
  } else {
    return [];
  }
}

ChatFile? chatFileFromMap(Map<String, dynamic>? map) {
  if (map == null) return null;

  final filePath = map['source'] as String?;
  final fileName = map['name'] as String?;

  if (filePath == null || fileName == null) {
    return null;
  }
  return ChatFile.fromFilePath(filePath);
}

class MetadataCollection {
  MetadataCollection({
    required this.sources,
    this.progress,
  });
  final List<ChatMessageRefSource> sources;
  final AIChatProgress? progress;
}

MetadataCollection parseMetadata(String? s) {
  if (s == null || s.trim().isEmpty || s.toLowerCase() == "null") {
    return MetadataCollection(sources: []);
  }

  final List<ChatMessageRefSource> metadata = [];
  AIChatProgress? progress;

  try {
    final dynamic decodedJson = jsonDecode(s);
    if (decodedJson == null) {
      return MetadataCollection(sources: []);
    }

    void processMap(Map<String, dynamic> map) {
      if (map.containsKey("step") && map["step"] != null) {
        progress = AIChatProgress.fromJson(map);
      } else if (map.containsKey("id") && map["id"] != null) {
        metadata.add(ChatMessageRefSource.fromJson(map));
      }
    }

    if (decodedJson is Map<String, dynamic>) {
      processMap(decodedJson);
    } else if (decodedJson is List) {
      for (final element in decodedJson) {
        if (element is Map<String, dynamic>) {
          processMap(element);
        }
      }
    }
  } catch (_) {
    return MetadataCollection(sources: []);
  }

  return MetadataCollection(sources: metadata, progress: progress);
}

Future<List<ChatMessageMeta>> metadataFromMetadata(
  Map<String, dynamic>? map,
) async {
  if (map == null) return [];

  final List<ChatMessageMeta> metadata = [];

  for (final value in map.values) {
    if (value is ChatViewReference) {
      final source = value.isDocumentView ? appflowySource : value.id;
      metadata.add(
        ChatMessageMeta(
          id: value.id,
          name: value.name,
          data: value.isDocumentView ? 'Document content placeholder' : '',
          loaderType: ContextLoaderType.txt,
          source: source,
        ),
      );
    } else if (value is ChatFile) {
      metadata.add(
        ChatMessageMeta(
          id: value.filePath,
          name: value.fileName,
          data: value.filePath,
          loaderType: value.fileType,
          source: value.filePath,
        ),
      );
    }
  }

  return metadata;
}

List<ChatFile> chatFilesFromMessageMetadata(
  Map<String, dynamic>? map,
) {
  final List<ChatFile> metadata = [];
  if (map != null) {
    for (final entry in map.entries) {
      if (entry.value is ChatFile) {
        metadata.add(entry.value as ChatFile);
      }
    }
  }

  return metadata;
}
