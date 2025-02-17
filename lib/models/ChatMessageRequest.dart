class ChatMessageRequest {
  num? roomId;
  String? content;
  String? sender;
  List<String>? imagesList;
  String? timestamp;

  ChatMessageRequest(
      {this.roomId,
      this.content,
      this.sender,
      this.imagesList,
      this.timestamp});

  ChatMessageRequest copyWith(
          {num? roomId,
          String? content,
          String? sender,
          List<String>? imagesList,
          List<String>? imagessList,
          String? timestamp}) =>
      ChatMessageRequest(
          roomId: roomId ?? this.roomId,
          content: content ?? this.content,
          sender: sender ?? this.sender,
          imagesList: imagesList ?? this.imagesList,
          timestamp: timestamp ?? this.timestamp);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["roomId"] = roomId;
    map["content"] = content;
    map["sender"] = sender;
    map["images"] = imagesList;
    map["timestamp"] = timestamp;
    return map;
  }

  ChatMessageRequest.fromJson(dynamic json) {
    roomId = json["roomId"];
    content = json["content"];
    sender = json["sender"];
    imagesList = json["images"] != null ? json["images"].cast<String>() : [];
    timestamp = json["timestamp"];
  }
}
