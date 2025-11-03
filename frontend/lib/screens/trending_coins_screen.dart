import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TrendingCoinsScreen extends StatefulWidget {
  const TrendingCoinsScreen({super.key});

  @override
  State<TrendingCoinsScreen> createState() => _TrendingCoinsScreenState();
}

class _TrendingCoinsScreenState extends State<TrendingCoinsScreen> {
  List trending = [];
  bool loading = true;

  Future<void> fetchTrending() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/search/trending');
      trending = response.data['coins'] ?? [];
    } catch (e) {
      trending = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchTrending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trending Coins'), backgroundColor: Colors.blue[900]),
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
                itemCount: trending.length,
                itemBuilder: (context, i) {
                  final coin = trending[i]['item'];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Image.network(coin['small'], width: 32),
                      title: Text('${coin['name']} (${coin['symbol'].toUpperCase()})'),
                      subtitle: Text('Rank: ${coin['market_cap_rank']}'),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
                      onTap: () {
                        Navigator.pushNamed(context, '/coin_detail', arguments: coin['id']);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}