// ...existing code...
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
  List<dynamic> watchlist = [];
  bool loading = true;
  String? errorMessage;

  Future<void> fetchWatchlist() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final resp = await _dio.get('/watchlist');
      final data = resp.data;
      if (data is Map && data.containsKey('watchlist')) {
        watchlist = List.from(data['watchlist']);
      } else if (data is List) {
        watchlist = List.from(data);
      } else {
        watchlist = [];
      }
    } catch (e) {
      errorMessage = 'Failed to load watchlist';
      watchlist = [];
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist'), backgroundColor: Colors.blue[900]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: RefreshIndicator(
          onRefresh: fetchWatchlist,
          child: loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : errorMessage != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white70))),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            onPressed: fetchWatchlist,
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    )
                  : watchlist.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No items in watchlist', style: TextStyle(color: Colors.white70))),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: watchlist.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, i) {
                            final coin = watchlist[i] is Map ? Map<String, dynamic>.from(watchlist[i]) : {};
                            final name = (coin['name'] ?? coin['title'] ?? coin['symbol'])?.toString() ?? 'Unknown';
                            final symbol = (coin['symbol'] ?? '').toString();
                            final price = coin['price']?.toString() ?? coin['current_price']?.toString() ?? '-';
                            final imageUrl = (coin['image'] is String) ? coin['image'] : (coin['image'] is Map ? (coin['image']['small'] ?? coin['image']['thumb'] ?? '') : '');
                            return Card(
                              color: Colors.white.withOpacity(0.95),
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              child: ListTile(
                                leading: imageUrl != null && imageUrl.isNotEmpty
                                    ? CircleAvatar(backgroundColor: Colors.transparent, child: CachedNetworkImage(imageUrl: imageUrl, width: 36, height: 36, errorWidget: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: Colors.orange)))
                                    : const CircleAvatar(child: Icon(Icons.currency_bitcoin, color: Colors.orange)),
                                title: Text('$name ${symbol.isNotEmpty ? '($symbol)':''}'),
                                subtitle: Text('Price: \$${price.toString()}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () => Navigator.pushNamed(context, '/coin_detail', arguments: coin['id'] ?? coin['symbol'] ?? name.toLowerCase()),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}