// ...existing code...
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProfileScreen extends StatefulWidget {
  /// Optionally pass the username as route argument:
  /// Navigator.pushNamed(context, '/profile', arguments: 'alice');
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> profile = {};
  List users = [];
  bool loading = true;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));

  Future<void> fetchProfile({String? username}) async {
    setState(() => loading = true);
    try {
      final resp = await _dio.get('/profile', queryParameters: username != null ? {'username': username} : null);
      if (resp.data is Map && resp.data.containsKey('username')) {
        profile = Map<String, dynamic>.from(resp.data);
        users = [];
      } else if (resp.data is Map && resp.data.containsKey('users')) {
        users = List.from(resp.data['users']);
        profile = {};
      } else {
        // Fallback: if backend returns single user map
        profile = Map<String, dynamic>.from(resp.data);
        users = [];
      }
    } catch (e) {
      profile = {};
      users = [];
      // optionally show error toast/snackbar
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // we cannot read route args here; delay to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    final username = (arg is String) ? arg : null;
    fetchProfile(username: username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), backgroundColor: Colors.blue[900]),
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
            : profile.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(24),
                    child: Card(
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile['username'] ?? '—', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(profile['email'] ?? '—'),
                            SizedBox(height: 8),
                            Text('Admin: ${profile['is_admin'] == true ? "Yes" : "No"}'),
                            SizedBox(height: 8),
                            Text('Joined: ${profile['created_at'] ?? "—"}'),
                          ],
                        ),
                      ),
                    ),
                  )
                : users.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          final u = users[i];
                          return Card(
                            child: ListTile(
                              title: Text(u['username'] ?? '—'),
                              subtitle: Text(u['email'] ?? ''),
                              onTap: () => Navigator.pushNamed(context, '/profile', arguments: u['username']),
                            ),
                          );
                        },
                      )
                    : Center(child: Text('No profile data', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}