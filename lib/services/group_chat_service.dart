import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class GroupChatService {
  final _storage = const FlutterSecureStorage();
  StompClient? _stompClient;
  bool _isConnected = false;

  Future<void> connect({
    required Function(Map<String, dynamic>) onMessageReceived,
    Function()? onConnect,
    Function(dynamic error)? onError,
  }) async {
    final token = await _storage.read(key: 'token');

    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://localhost:8080/ws', // đổi nếu dùng IP thật
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: (StompFrame frame) {
          _isConnected = true;
          _stompClient?.subscribe(
            destination: '/topic/chat/group',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                onMessageReceived(data);
              }
            },
          );
          onConnect?.call();
        },
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 300));
        },
        onWebSocketError: onError ?? (error) => print('WebSocket error: $error'),
        onDisconnect: (_) {
          _isConnected = false;
          print("❌ Disconnected");
        },
      ),
    );

    _stompClient?.activate();
  }

  void sendGroupMessage(String content) {
    if (!_isConnected || _stompClient == null) return;

    final message = {
      'content': content,
      'type': 'GROUP',
    };

    _stompClient?.send(
      destination: '/app/chat.group',
      body: jsonEncode(message),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}
