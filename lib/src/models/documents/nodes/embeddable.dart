import 'dart:convert';

/// An object which can be embedded into a Quill document.
///
/// See also:
///
/// * [BlockEmbed] which represents a block embed.
class Embeddable {
  const Embeddable(this.type, this.data);

  /// The type of this object.
  final String type;

  /// The data payload of this object.
  final dynamic data;

  // 修改
  // Map<String, dynamic> toJson() {
  //   final m = <String, String>{type: data};
  //   return m;
  // }
  Map<String, dynamic> toJson() {
    if (type == 'image' || type == 'video' || type == 'question') {
      return data is Map ? data : toFormalJson();
    }
    return toFormalJson();
  }

  Map<String, dynamic> toFormalJson() {
    return {type: data};
  }

  // 修改，添加length属性
  int get length => 1;

  // 修改
  // static Embeddable fromJson(Map<String, dynamic> json) {
  //   final m = Map<String, dynamic>.from(json);
  //   assert(m.length == 1, 'Embeddable map must only have one key');
  //
  //   return BlockEmbed(m.keys.first, m.values.first);
  // }
  static Embeddable fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    assert(m.isNotEmpty, 'Embeddable can not be empty');
    if (m.length > 1 && m.containsKey('_type')) {
      final type = m['_type'];
      if (type == 'image') {
        return ImageEmbed.fromJson(m);
      }
      if (type == 'video') {
        return VideoEmbed.fromJson(m);
      }
      if (type == 'question') {
        return QuestionEmbed.fromJson(m);
      }
    }
    if (m.containsKey('image')) {
      return ImageEmbed.fromJson(m['image']);
    }
    if (m.containsKey('video')) {
      return VideoEmbed.fromJson(m['video']);
    }
    if (m.containsKey('mention')) {
      return MentionEmbed.fromJson(m['mention']);
    }
    if (m.containsKey('question')) {
      return QuestionEmbed.fromJson(m['question']);
    }
    return BlockEmbed(m.keys.first, m.values.first);
  }
}

/// There are two built-in embed types supported by Quill documents, however
/// the document model itself does not make any assumptions about the types
/// of embedded objects and allows users to define their own types.
class BlockEmbed extends Embeddable {
  const BlockEmbed(String type, String data) : super(type, data);

  static const String imageType = 'image';

  static BlockEmbed image(String imageUrl) => BlockEmbed(imageType, imageUrl);

  static const String videoType = 'video';

  static BlockEmbed video(String videoUrl) => BlockEmbed(videoType, videoUrl);

  static const String questionType = 'question';

  static BlockEmbed question(String link) => BlockEmbed(questionType, link);

  static const String formulaType = 'formula';
  static BlockEmbed formula(String formula) => BlockEmbed(formulaType, formula);

  static const String customType = 'custom';
  static BlockEmbed custom(CustomBlockEmbed customBlock) =>
      BlockEmbed(customType, customBlock.toJsonString());
}

class CustomBlockEmbed extends BlockEmbed {
  const CustomBlockEmbed(String type, String data) : super(type, data);

  String toJsonString() => jsonEncode(toJson());

  static CustomBlockEmbed fromJsonString(String data) {
    final embeddable = Embeddable.fromJson(jsonDecode(data));
    return CustomBlockEmbed(embeddable.type, embeddable.data);
  }
}

// 修改
class ImageEmbed extends Embeddable {
  ImageEmbed({
    required this.source,
    required this.width,
    required this.height,
    this.name,
    this.checkPath,
    this.size,
  }) : super('image', {
          'name': name,
          'source': source,
          'width': width,
          'height': height,
          'checkPath': checkPath,
          '_type': 'image',
          '_inline': false,
          'size': size,
        });

  final String? name;
  final String? checkPath;
  final String source;
  final num width;
  final num height;
  num? size;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'source': source,
      'width': width,
      'height': height,
      'checkPath': checkPath,
      '_type': 'image',
      '_inline': false,
      'size': size ?? 0,
    };
  }

  @override
  Map<String, dynamic> toFormalJson() {
    final res = <String, dynamic>{
      'image': toJson(),
    };
    return res;
  }

  static ImageEmbed fromJson(Map<String, dynamic> data) {
    num width = 0;
    if (data['width'] is String) {
      width = num.tryParse(data['width']) ?? 0;
    } else if (data['width'] is num) {
      width = data['width'];
    }
    num height = 0;
    if (data['height'] is String) {
      height = num.tryParse(data['height']) ?? 0;
    } else if (data['height'] is num) {
      height = data['height'];
    }
    num size = 0;
    if (data['size'] is String) {
      size = num.tryParse(data['size']) ?? 0;
    } else if (data['size'] is num) {
      size = data['size'];
    }
    return ImageEmbed(
      name: data['name'] as String?,
      source: data['source'] as String,
      checkPath: data['checkPath'] as String?,
      width: width,
      height: height,
      size: size,
    );
  }
}

class VideoEmbed extends Embeddable {
  VideoEmbed({
    required this.width,
    required this.height,
    required this.source,
    required this.fileType,
    required this.duration,
    required this.thumbUrl,
    this.thumbName,
    this.name,
  }) : super('video', {
          'width': width,
          'height': height,
          'source': source,
          'fileType': fileType,
          'duration': duration,
          'thumbUrl': thumbUrl,
          'thumbName': thumbName,
          '_type': 'video',
          '_inline': false,
          'name': name,
        });

  final num width;
  final num height;
  final String source;
  final String fileType;
  final num duration;
  final String thumbUrl;
  final String? thumbName;
  final String? name;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'source': source,
      'fileType': fileType,
      'duration': duration,
      'thumbUrl': thumbUrl,
      'thumbName': thumbName,
      '_type': 'video',
      '_inline': false,
      'name': name,
    };
  }

  @override
  Map<String, dynamic> toFormalJson() {
    return <String, dynamic>{
      'video': toJson(),
    };
  }

  static VideoEmbed fromJson(Map<String, dynamic> data) {
    num width = 0;
    if (data['width'] is String) {
      width = num.tryParse(data['width']) ?? 0;
    } else if (data['width'] is num) {
      width = data['width'];
    }
    num height = 0;
    if (data['height'] is String) {
      height = num.tryParse(data['height']) ?? 0;
    } else if (data['height'] is num) {
      height = data['height'];
    }
    num duration = 0;
    if (data['duration'] is String) {
      duration = num.tryParse(data['duration']) ?? 0;
    } else if (data['duration'] is num) {
      duration = data['duration'];
    }
    return VideoEmbed(
      width: width,
      height: height,
      source: data['source'],
      fileType: data['fileType'],
      duration: duration,
      thumbUrl: data['thumbUrl'],
      thumbName: data['thumbName'],
      name: data['name'],
    );
  }
}

/// 问题卡片
class QuestionEmbed extends Embeddable {
  QuestionEmbed({
    required this.link,
  }) : super('question', {
          'link': link,
          '_type': 'question',
        });

  final String? link;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'link': link ?? '',
      '_type': 'question',
    };
  }

  @override
  Map<String, dynamic> toFormalJson() {
    final res = <String, dynamic>{
      'question': toJson(),
    };
    return res;
  }

  static QuestionEmbed fromJson(Map<String, dynamic> data) {
    var tempLink = '';
    if (data['link'] is String) {
      tempLink = data['link'] as String;
    }
    return QuestionEmbed(
      link: tempLink,
    );
  }
}

class MentionEmbed extends Embeddable {
  MentionEmbed({
    required this.denotationChar,
    required this.id,
    required this.value,
    required this.prefixChar,
    String? type,
  }) : super(type ?? 'mention', {
          'denotationChar': denotationChar,
          'id': id,
          'value': value,
          'prefixChar': prefixChar,
        });

  String denotationChar;
  String id;
  String value;
  String prefixChar;

  String get attributeKey {
    switch (prefixChar) {
      case '@':
        return 'at';
      case 'at':
        return 'at';
      case 'channel':
        return 'channel';
      case '#':
        return 'channel';
      default:
        return 'at';
    }
  }

  @override
  Map<String, dynamic> toFormalJson() {
    return <String, dynamic>{
      'mention': {
        'denotationChar': denotationChar,
        'id': id,
        'value': value,
        'prefixChar': prefixChar,
      },
    };
  }

  @override
  int get length {
    return value.length;
  }

  static MentionEmbed fromJson(Map<String, dynamic> data) {
    return MentionEmbed(
      denotationChar: data['denotationChar'],
      id: data['id'],
      value: data['value'],
      prefixChar: data['prefixChar'],
    );
  }

  static MentionEmbed fromAttribute(
      String id, String prefixChar, String value, {String? type}) {
    return MentionEmbed(
      denotationChar: '',
      id: id,
      value: value,
      prefixChar: prefixChar,
      type: type,
    );
  }
}
