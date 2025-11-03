// Admin Panel Screen
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List users = [];
  bool loading = true;

  Future<void> fetchUsers() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/admin/users');
      users = response.data ?? [];
    } catch (e) {
      users = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel'), backgroundColor: Colors.blue[900]),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: loading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final user = users[i];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text(user['username'] ?? ''),
                      subtitle: Text(user['email'] ?? ''),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
