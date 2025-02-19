class ChatMessageRequest {
  num? roomId;
  String? content;
  String? sender;
  List<String>? images;
  List<String>? imagess;
  String? timestamp;

  ChatMessageRequest(
      {this.roomId,
      this.content,
      this.sender,
      this.images,
      this.timestamp,
      this.imagess});

  ChatMessageRequest copyWith(
          {num? roomId,
          String? content,
          String? sender,
          List<String>? images,
          String? timestamp}) =>
      ChatMessageRequest(
          roomId: roomId ?? this.roomId,
          content: content ?? this.content,
          sender: sender ?? this.sender,
          images: images ?? this.images,
          timestamp: timestamp ?? this.timestamp);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["roomId"] = roomId;
    map["content"] = content;
    map["sender"] = sender;
    map["images"] = images;
    map["imagess"] = imagess;
    map["timestamp"] = timestamp;
    return map;
  }

  ChatMessageRequest.fromJson(dynamic json) {
    roomId = json["roomId"];
    content = json["content"];
    sender = json["sender"];
    images = json["images"] != null ? json["images"].cast<String>() : [];
    imagess = json["imagess"] != null ? json["imagess"].cast<String>() : [];
    timestamp = json["timestamp"];
  }
}
