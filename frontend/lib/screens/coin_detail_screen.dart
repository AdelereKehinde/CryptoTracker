import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CoinDetailScreen extends StatefulWidget {
  const CoinDetailScreen({Key? key}) : super(key: key);

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  Map<String, dynamic> coin = {};
  bool loading = true;
  String? coinId;

  Future<void> fetchCoin(String id) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('http://localhost:8000/coins/$id');
      coin = response.data ?? {};
    } catch (e) {
      coin = {};
    }
    setState(() => loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 👇 safely read the id from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      coinId = args;
      fetchCoin(coinId!);
    } else {
      // fallback or error handling if id is missing
      coinId = null;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Details'),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : coinId == null
                ? const Center(
                    child: Text('Invalid coin ID passed',
                        style: TextStyle(color: Colors.white)),
                  )
                : coin.isEmpty
                    ? const Center(
                        child: Text('No data found',
                            style: TextStyle(color: Colors.white)))
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // 🪙 Coin Image
                          Center(
                            child: Hero(
                              tag: coinId!,
                              child: Image.network(
                                coin['image'] is String
                                    ? coin['image']
                                    : (coin['image']?['large'] ??
                                        coin['image']?['small'] ??
                                        coin['image']?['thumb'] ??
                                        ''),
                                height: 100,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.currency_bitcoin,
                                  size: 80,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 🏷 Name and Symbol
                          Center(
                            child: Text(
                              '${coin['name']} (${coin['symbol']?.toString().toUpperCase() ?? ''})',
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 💰 Current Price
                          _infoCard(
                            title: 'Current Price',
                            value:
                                '\$${coin['market_data']?['current_price']?['usd'] ?? 'N/A'}',
                          ),
                          // 📊 Market Cap
                          _infoCard(
                            title: 'Market Cap',
                            value:
                                '\$${coin['market_data']?['market_cap']?['usd'] ?? 'N/A'}',
                          ),
                          // 🪙 Circulating Supply
                          _infoCard(
                            title: 'Circulating Supply',
                            value:
                                '${coin['market_data']?['circulating_supply'] ?? 'N/A'}',
                          ),
                          // 🏆 Rank
                          _infoCard(
                            title: 'Market Cap Rank',
                            value: '#${coin['market_cap_rank'] ?? 'N/A'}',
                          ),
                          // 📈 24h Change
                          _infoCard(
                            title: '24h Price Change',
                            value:
                                '${coin['market_data']?['price_change_percentage_24h']?.toStringAsFixed(2) ?? 'N/A'}%',
                          ),
                          // 📅 Last Updated
                          _infoCard(
                            title: 'Last Updated',
                            value: coin['last_updated'] ?? 'N/A',
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Description:',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            (coin['description']?['en'] ??
                                    'No description available')
                                .toString()
                                .replaceAll(RegExp(r'<[^>]*>'), ''), // remove HTML tags
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _infoCard({required String title, required String value}) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

