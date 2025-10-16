import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? channel;

  void connect() {
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8000/ws/market'));
  }

  Stream get stream => channel!.stream;

  void disconnect() {
    channel?.sink.close();
  }
}