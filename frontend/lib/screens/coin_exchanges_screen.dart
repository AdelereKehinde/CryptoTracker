// Coin Exchanges Screen
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
class CoinExchangesScreen extends StatefulWidget {
  const CoinExchangesScreen({super.key});

  @override
  State<CoinExchangesScreen> createState() => _CoinExchangesScreenState();
}

class _CoinExchangesScreenState extends State<CoinExchangesScreen> {
  List exchanges = [];
  bool loading = true;

  Future<void> fetchExchanges(String id) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/coins/$id/tickers');
      exchanges = response.data['tickers'] ?? [];
    } catch (e) {
      exchanges = [];
    }
    setState(() => loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String? ?? 'bitcoin';
    fetchExchanges(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Coin Exchanges'), backgroundColor: Colors.blue[900]),
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
                itemCount: exchanges.length,
                itemBuilder: (context, i) {
                  final ex = exchanges[i];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz, color: Colors.blue),
                      title: Text(ex['market']['name'] ?? ''),
                      subtitle: Text('Pair: ${ex['base']}/${ex['target']}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
