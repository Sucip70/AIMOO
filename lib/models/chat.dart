import 'package:collection/collection.dart';

enum OpenAIChatMessageRole { system, user, assistant, function, tool }

final class OpenAIStreamChatCompletionModel {
  final String id;
  final DateTime created;
  final List<OpenAIStreamChatCompletionChoiceModel> choices;
  final String? systemFingerprint;
  bool get haveChoices => choices.isNotEmpty;
  bool get haveSystemFingerprint => systemFingerprint != null;

  @override
  int get hashCode {
    return id.hashCode ^
        created.hashCode ^
        choices.hashCode ^
        systemFingerprint.hashCode;
  }

  const OpenAIStreamChatCompletionModel({
    required this.id,
    required this.created,
    required this.choices,
    required this.systemFingerprint,
  });

  factory OpenAIStreamChatCompletionModel.fromMap(Map<String, dynamic> json) {
    return OpenAIStreamChatCompletionModel(
      id: json['id'],
      created: DateTime.fromMillisecondsSinceEpoch(json['created'] * 1000),
      choices: (json['choices'] as List)
          .map(
            (choice) => OpenAIStreamChatCompletionChoiceModel.fromMap(choice),
          )
          .toList(),
      systemFingerprint: json['system_fingerprint'],
    );
  }

  @override
  String toString() {
    return 'OpenAIStreamChatCompletionModel(id: $id, created: $created, choices: $choices, systemFingerprint: $systemFingerprint)';
  }

  @override
  bool operator ==(Object other) {
    const ListEquality listEquals = ListEquality();
    if (identical(this, other)) return true;

    return other is OpenAIStreamChatCompletionModel &&
        other.id == id &&
        other.created == created &&
        listEquals.equals(other.choices, choices) &&
        other.systemFingerprint == systemFingerprint;
  }
}

final class OpenAIStreamChatCompletionChoiceModel {
  final int index;
  final OpenAIStreamChatCompletionChoiceDeltaModel delta;
  final String? finishReason;
  bool get hasFinishReason => finishReason != null;

  @override
  int get hashCode {
    return index.hashCode ^ delta.hashCode ^ finishReason.hashCode;
  }

  const OpenAIStreamChatCompletionChoiceModel({
    required this.index,
    required this.delta,
    required this.finishReason,
  });

  factory OpenAIStreamChatCompletionChoiceModel.fromMap(
    Map<String, dynamic> json,
  ) {
    return OpenAIStreamChatCompletionChoiceModel(
      index: json['index'],
      delta: OpenAIStreamChatCompletionChoiceDeltaModel.fromMap(json['delta']),
      finishReason: json['finish_reason'],
    );
  }

  @override
  String toString() {
    return 'OpenAIStreamChatCompletionChoiceModel(index: $index, delta: $delta, finishReason: $finishReason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OpenAIStreamChatCompletionChoiceModel &&
        other.index == index &&
        other.delta == delta &&
        other.finishReason == finishReason;
  }
}

final class OpenAIStreamChatCompletionChoiceDeltaModel {
  final OpenAIChatMessageRole? role;
  final List<OpenAIChatCompletionChoiceMessageContentItemModel?>? content;
  // final List<OpenAIResponseToolCall>? toolCalls;
  // bool get haveToolCalls => toolCalls != null;
  bool get haveRole => role != null;
  bool get haveContent => content != null;

  // @override
  // int get hashCode {
  //   return role.hashCode ^ content.hashCode ^ toolCalls.hashCode;
  // }

  const OpenAIStreamChatCompletionChoiceDeltaModel({
    required this.role,
    required this.content,
    // this.toolCalls,
  });

  factory OpenAIStreamChatCompletionChoiceDeltaModel.fromMap(
    Map<String, dynamic> json,
  ) {
    return OpenAIStreamChatCompletionChoiceDeltaModel(
      role: json['role'] != null
          ? OpenAIChatMessageRole.values
              .firstWhere((role) => role.name == json['role'])
          : null,
      content: json['content'] != null
          ? OpenAIMessageDynamicContentFromFieldAdapter.dynamicContentFromField(
              json['content'],
            )
          : null,
      // toolCalls: json['tool_calls'] != null
      //     ? (json['tool_calls'] as List)
      //         .map((toolCall) => OpenAIStreamResponseToolCall.fromMap(toolCall))
      //         .toList()
      //     : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "role": role?.name,
      "content": content,
      // "tool_calls": toolCalls?.map((toolCall) => toolCall.toMap()).toList(),
    };
  }

  @override
  String toString() {
    String str = 'OpenAIChatCompletionChoiceMessageModel('
        'role: $role, '
        'content: $content, ';
    // if (toolCalls != null) {
    //   str += 'toolCalls: $toolCalls, ';
    // }
    str += ')';
    return str;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OpenAIStreamChatCompletionChoiceDeltaModel &&
        other.role == role &&
        other.content == content 
        // &&
        // other.toolCalls == toolCalls
        ;
  }
}

mixin class OpenAIMessageDynamicContentFromFieldAdapter {
  static List<OpenAIChatCompletionChoiceMessageContentItemModel>
      dynamicContentFromField(
    fieldData,
  ) {
    if (fieldData is String) {
      return _singleItemListFrom(fieldData);
    } else if (fieldData is List) {
      return _listOfContentItemsFrom(fieldData);
    } else {
      throw Exception(
        'Invalid content type, nor text or list, please report this issue.',
      );
    }
  }

  static List<OpenAIChatCompletionChoiceMessageContentItemModel>
      _singleItemListFrom(String directTextContent) {
    return [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        directTextContent,
      ),
    ];
  }

  static List<OpenAIChatCompletionChoiceMessageContentItemModel>
      _listOfContentItemsFrom(List listOfContentsItems) {
    return (listOfContentsItems).map(
      (item) {
        if (item is! Map) {
          throw Exception('Invalid content item, please report this issue.');
        } else {
          final asMap = item as Map<String, dynamic>;

          return OpenAIChatCompletionChoiceMessageContentItemModel.fromMap(
            asMap,
          );
        }
      },
    ).toList();
  }
}


class OpenAIChatCompletionChoiceMessageContentItemModel {
  final String type;
  final String? text;
  final String? imageUrl;

  @override
  int get hashCode => type.hashCode ^ text.hashCode ^ imageUrl.hashCode;

  OpenAIChatCompletionChoiceMessageContentItemModel._({
    required this.type,
    this.text,
    this.imageUrl,
  });

  factory OpenAIChatCompletionChoiceMessageContentItemModel.fromMap(
    Map<String, dynamic> asMap,
  ) {
    return OpenAIChatCompletionChoiceMessageContentItemModel._(
      type: asMap['type'],
      text: asMap['text'],
      imageUrl: asMap['image_url'],
    );
  }

  factory OpenAIChatCompletionChoiceMessageContentItemModel.text(String text) {
    return OpenAIChatCompletionChoiceMessageContentItemModel._(
      type: 'text',
      text: text,
    );
  }

  factory OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
    String imageUrl,
  ) {
    return OpenAIChatCompletionChoiceMessageContentItemModel._(
      type: 'image_url',
      imageUrl: imageUrl,
    );
  }

  /// This method used to convert the [OpenAIChatCompletionChoiceMessageContentItemModel] to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      if (text != null) "text": text,
      if (imageUrl != null) "image_url": imageUrl,
    };
  }

  @override
  bool operator ==(
    covariant OpenAIChatCompletionChoiceMessageContentItemModel other,
  ) {
    if (identical(this, other)) return true;

    return other.type == type &&
        other.text == text &&
        other.imageUrl == imageUrl;
  }

  @override
  String toString() => switch (type) {
        'text' =>
          'OpenAIChatCompletionChoiceMessageContentItemModel(type: $type, text: $text)',
        'image' =>
          'OpenAIChatCompletionChoiceMessageContentItemModel(type: $type, imageUrl: $imageUrl)',
        _ => 'OpenAIChatCompletionChoiceMessageContentItemModel(type: $type)',
      };
}
