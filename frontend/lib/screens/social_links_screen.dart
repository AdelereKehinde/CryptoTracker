import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SocialLinksScreen extends StatefulWidget {
  const SocialLinksScreen({super.key});

  @override
  State<SocialLinksScreen> createState() => _SocialLinksScreenState();
}

class _SocialLinksScreenState extends State<SocialLinksScreen> {
  Map links = {};
  bool loading = true;

  Future<void> fetchLinks(String id) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/coins/$id');
      links = response.data['links'] ?? {};
    } catch (e) {
      links = {};
    }
    setState(() => loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String? ?? 'bitcoin';
    fetchLinks(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Social & Links'), backgroundColor: Colors.blue[900]),
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
            : links.isEmpty
                ? Center(child: Text('No links found', style: TextStyle(color: Colors.white)))
                : ListView(
                    padding: EdgeInsets.all(24),
                    children: [
                      if (links['homepage'] != null && links['homepage'][0] != '')
                        ListTile(
                          leading: Icon(Icons.link, color: Colors.blue),
                          title: Text('Website'),
                          subtitle: Text(links['homepage'][0]),
                        ),
                      if (links['twitter_screen_name'] != null && links['twitter_screen_name'] != '')
                        ListTile(
                          leading: Icon(Icons.alternate_email, color: Colors.blue),
                          title: Text('Twitter'),
                          subtitle: Text('@${links['twitter_screen_name']}'),
                        ),
                      if (links['subreddit_url'] != null && links['subreddit_url'] != '')
                        ListTile(
                          leading: Icon(Icons.reddit, color: Colors.orange),
                          title: Text('Reddit'),
                          subtitle: Text(links['subreddit_url']),
                        ),
                      // Add more social links as needed
                    ],
                  ),
      ),
    );
  }
}