# Test Plan: chat_message_service

## Parsing metadata
- Map input with `step` -> returns AIChatProgress
- List of maps containing `id/name/source` -> returns list of ChatMessageRefSource
- Invalid JSON -> returns empty result
- Malformed JSON in chatFilesFromMetadataString -> should handle gracefully

## chatFileFromMap
- Null/empty map -> null
- Map with invalid path -> null
- Map with valid path -> ChatFile with correct loader type for .pdf/.txt/.md

## metadataFromMetadata (placeholder behavior)
- With ChatViewReference -> produces ChatMessageMeta with txt loader type
- With ChatFile -> produces ChatMessageMeta reflecting file path/type
