class ChatMessageResponse {
  num? id;
  String? content;
  num? roomId;
  String? senderId;
  DateTime? timestamp;
  List<String>? imagesList;

  ChatMessageResponse(
      {this.id,
      this.content,
      this.roomId,
      this.senderId,
      this.timestamp,
      this.imagesList});

  ChatMessageResponse copyWith(
          {num? id,
          String? content,
          num? roomId,
          String? senderId,
          DateTime? timestamp,
          List<String>? imagesList}) =>
      ChatMessageResponse(
          id: id ?? this.id,
          content: content ?? this.content,
          roomId: roomId ?? this.roomId,
          senderId: senderId ?? this.senderId,
          timestamp: timestamp ?? this.timestamp,
          imagesList: imagesList ?? this.imagesList);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["content"] = content;
    map["roomId"] = roomId;
    map["senderId"] = senderId;
    map["timestamp"] = timestamp?.toIso8601String();
    map["images"] = imagesList;
    return map;
  }

  ChatMessageResponse.fromJson(dynamic json) {
    id = json["id"];
    content = json["content"];
    roomId = json["roomId"];
    senderId = json["senderId"];
    timestamp = json["timestamp"] != null
        ? (json["timestamp"] is int
            ? DateTime.fromMillisecondsSinceEpoch(json["timestamp"])
            : DateTime.parse(json["timestamp"]))
        : null;
    imagesList = json["images"] != null ? json["images"].cast<String>() : [];
  }
}
