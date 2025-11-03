import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TokenDetailScreen extends StatefulWidget {
  const TokenDetailScreen({super.key});

  @override
  State<TokenDetailScreen> createState() => _TokenDetailScreenState();
}

class _TokenDetailScreenState extends State<TokenDetailScreen> {
  Map token = {};
  bool loading = true;

  Future<void> fetchToken(String id) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/coins/$id');
      token = response.data;
    } catch (e) {
      token = {};
    }
    setState(() => loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String? ?? 'bitcoin';
    fetchToken(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Token Detail'), backgroundColor: Colors.blue[900]),
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
            : token.isEmpty
                ? Center(child: Text('No data', style: TextStyle(color: Colors.white)))
                : ListView(
                    padding: EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Image.network(token['image'], width: 64),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          '${token['name']} (${token['symbol'].toUpperCase()})',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text('Current Price'),
                          trailing: Text('\$${token['market_data']['current_price']['usd']}'),
                        ),
                      ),
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text('Market Cap'),
                          trailing: Text('\$${token['market_data']['market_cap']['usd']}'),
                        ),
                      ),
                      // Add more analytics, charts, etc.
                    ],
                  ),
      ),
    );
  }
}