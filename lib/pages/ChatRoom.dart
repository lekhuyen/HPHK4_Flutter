import 'dart:convert';

import 'package:fe/models/ChatMessageRequest.dart';
import 'package:fe/models/ChatMessageResponse.dart';
import 'package:fe/pages/OtherMsgWidget.dart';
import 'package:fe/pages/OwnMsgWidget.dart';
import 'package:fe/services/ApiChatService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatRoom extends StatefulWidget {
  final String userName;
  final int roomId;
  final String userId;
  const ChatRoom(
      {super.key,
      required this.userName,
      required this.roomId,
      required this.userId});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final ApiChatService apiChatService = ApiChatService();
  List<ChatMessageResponse> chatMessageLists = [];
  StompClient? stompClient;

  TextEditingController msgController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatRooms();
    connectWebSocket();
  }

  void connectWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("🚨 Không tìm thấy token, không thể kết nối WebSocket!");
      return;
    }

    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://192.168.1.30:8080/ws',
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        reconnectDelay: const Duration(seconds: 3),
        onConnect: (StompFrame frame) {
          print("✅ Connected to WebSocket");
          stompClient!.subscribe(
            destination: '/topic/room/${widget.roomId}',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                var response = jsonDecode(frame.body!);
                print(" New message: ${response['content']}");
                setState(() {
                  chatMessageLists.add(ChatMessageResponse.fromJson(response));
                });
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          print("❌ WebSocket Error: $error");
        },
        onDisconnect: (StompFrame frame) {
          print("⚠️ WebSocket bị ngắt kết nối! Đang thử kết nối lại...");
          Future.delayed(const Duration(seconds: 3), () {
            connectWebSocket(); // 🔄 Tự động kết nối lại
          });
        },
      ),
    );

    stompClient!.activate();
  }

  void sendMessage() async {
    if (msgController.text.isEmpty) return;

    ChatMessageRequest newChatMessageRequest = ChatMessageRequest(
      roomId: widget.roomId,
      content: msgController.text,
      sender: widget.userId,
      timestamp: DateTime.now().toIso8601String(),
    );

    try {
      ChatMessageResponse response =
          await apiChatService.sendMessage(newChatMessageRequest);

      setState(() {
        chatMessageLists.add(response);
      });

      // Kiểm tra và kết nối lại WebSocket nếu cần
      if (stompClient == null || !stompClient!.connected) {
        print("🚨 WebSocket chưa kết nối. Đang thử kết nối lại...");
        connectWebSocket();
      }

      if (stompClient != null && stompClient!.connected) {
        String messageJson = jsonEncode(response);
        stompClient!.send(destination: "/app/sendMessage", body: messageJson);
      } else {
        print("🚨 WebSocket vẫn chưa kết nối, tin nhắn không được gửi!");
      }

      // msgController.clear();
    } catch (e) {
      print("❌ Lỗi khi gửi tin nhắn: $e");
    }
  }

  Future<void> fetchChatRooms() async {
    try {
      List<ChatMessageResponse> messages =
          await apiChatService.getAllMessageByRoomId(widget.roomId);
      setState(() {
        chatMessageLists = messages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading chat rooms: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessageLists.length,
              itemBuilder: (context, index) {
                if (chatMessageLists[index].senderId == widget.userId) {
                  return OwnMsgWidget(
                      msg: chatMessageLists[index].content ?? '',
                      sender: chatMessageLists[index].senderId ?? '');
                } else {
                  return OtherMsgWidget(
                      msg: chatMessageLists[index].content ?? '',
                      sender: chatMessageLists[index].senderId ?? '');
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: msgController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          String msg = msgController.text;
                          if (msg.isNotEmpty) {
                            sendMessage();
                            msgController.clear();
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
