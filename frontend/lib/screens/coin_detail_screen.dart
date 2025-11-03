import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CoinDetailScreen extends StatefulWidget {
  const CoinDetailScreen({super.key});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  Map coin = {};
  bool loading = true;

  Future<void> fetchCoin(String id) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/coins/$id');
      coin = response.data;
    } catch (e) {
      coin = {};
    }
    setState(() => loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String;
    fetchCoin(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Detail'),
        backgroundColor: Colors.blue[900],
      ),
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
            : coin.isEmpty
                ? Center(child: Text('No data', style: TextStyle(color: Colors.white)))
                : ListView(
                    padding: EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Image.network(
                          coin['image'] is String
                              ? coin['image']
                              : (coin['image']?['large'] ?? coin['image']?['small'] ?? coin['image']?['thumb'] ?? ''),
                          width: 64,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.currency_bitcoin, size: 64, color: Colors.orange),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          ((coin['name'] is String ? coin['name'] : (coin['name']?['en'] ?? '')) +
                              ' (' +
                              (coin['symbol'] is String ? coin['symbol'].toUpperCase() : '') +
                              ')'),
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text('Current Price'),
                          trailing: Text('\$${coin['market_data']['current_price']['usd']}'),
                        ),
                      ),
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text('Market Cap'),
                          trailing: Text('\$${coin['market_data']['market_cap']['usd']}'),
                        ),
                      ),
                      // Add more analytics, charts, etc.
                    ],
                  ),
      ),
    );
  }
}