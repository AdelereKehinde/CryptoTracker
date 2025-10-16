// ...existing code...
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
  List<dynamic> notifications = [];
  bool loading = true;
  String? error;

  Future<void> fetchNotifications() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final resp = await _dio.get('/notifications');
      final data = resp.data;
      if (data is Map && data.containsKey('notifications')) {
        notifications = List.from(data['notifications']);
      } else if (data is List) {
        notifications = List.from(data);
      } else {
        notifications = [];
      }
    } catch (e) {
      error = 'Unable to load notifications';
      notifications = [];
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.blue[900]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: RefreshIndicator(
          onRefresh: fetchNotifications,
          child: loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : error != null
                  ? ListView(children: [const SizedBox(height: 120), Center(child: Text(error!, style: const TextStyle(color: Colors.white70))), Center(child: ElevatedButton(onPressed: fetchNotifications, child: const Text('Retry')))])
                  : notifications.isEmpty
                      ? ListView(children: const [SizedBox(height: 120), Center(child: Text('No notifications', style: TextStyle(color: Colors.white70)))])
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, i) {
                            final n = notifications[i] is Map ? Map<String, dynamic>.from(notifications[i]) : {};
                            return Card(
                              color: Colors.white.withOpacity(0.95),
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              child: ListTile(
                                leading: const Icon(Icons.notifications, color: Colors.blue),
                                title: Text(n['title'] ?? 'Notification'),
                                subtitle: Text(n['message'] ?? ''),
                                onTap: () {
                                  // handle notification tap
                                },
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}