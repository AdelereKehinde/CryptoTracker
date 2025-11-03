// Search Screen
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List results = [];
  bool loading = false;

  Future<void> searchCoins(String query) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/coins/list');
      results = (response.data as List)
          .where((coin) => coin['name'].toLowerCase().contains(query.toLowerCase()) || coin['symbol'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      results = [];
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search'), backgroundColor: Colors.blue[900]),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Search coins...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) {
                  if (v.length > 1) searchCoins(v);
                },
              ),
            ),
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final coin = results[i];
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('${coin['name']} (${coin['symbol'].toUpperCase()})'),
                            onTap: () {
                              Navigator.pushNamed(context, '/coin_detail', arguments: coin['id']);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
