// ...existing code...
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://cryptotracker-yof6.onrender.com/'));
  Map<String, dynamic> analytics = {};
  bool loading = true;
  String? error;

  Future<void> fetchAnalytics() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final resp = await _dio.get('/analytics');
      final data = resp.data;
      if (data is Map) {
        analytics = Map<String, dynamic>.from(data);
      } else {
        analytics = {};
      }
    } catch (e) {
      error = 'Failed to load analytics';
      analytics = {};
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  String _fmt(num? v) => v == null ? '—' : NumberFormat.compact().format(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard'), backgroundColor: Colors.blue[900], actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: fetchAnalytics)]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : error != null
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 12), ElevatedButton(onPressed: fetchAnalytics, child: const Text('Retry'))]))
                : ListView(padding: const EdgeInsets.all(16), children: [
                    Card(color: Colors.white.withOpacity(0.95), child: ListTile(leading: const Icon(Icons.show_chart), title: const Text('Total Market Cap'), trailing: Text(_fmt(analytics['market_cap'])))),
                    const SizedBox(height: 8),
                    Card(color: Colors.white.withOpacity(0.95), child: ListTile(leading: const Icon(Icons.swap_vert), title: const Text('24h Volume'), trailing: Text(_fmt(analytics['volume_24h'])))),
                    const SizedBox(height: 8),
                    Card(color: Colors.white.withOpacity(0.95), child: ListTile(leading: const Icon(Icons.pie_chart), title: const Text('BTC Dominance'), trailing: Text('${analytics['btc_dominance']?.toStringAsFixed(2) ?? '—'}%'))),
                    const SizedBox(height: 8),
                    Card(color: Colors.white.withOpacity(0.95), child: ListTile(leading: const Icon(Icons.trending_up), title: const Text('Top Gainer (24h)'), subtitle: Text(analytics['top_gainer']?.toString() ?? '—'))),
                    const SizedBox(height: 8),
                    Card(color: Colors.white.withOpacity(0.95), child: ListTile(leading: const Icon(Icons.trending_down), title: const Text('Top Loser (24h)'), subtitle: Text(analytics['top_loser']?.toString() ?? '—'))),
                    const SizedBox(height: 12),
                    const Text('Market Snapshot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // quick stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3.2,
                      children: [
                        _statTile('Active Coins', analytics['active_coins']),
                        _statTile('Exchanges', analytics['exchanges']),
                        _statTile('Pairs', analytics['pairs']),
                        _statTile('Markets Up (24h)', analytics['markets_up']),
                      ],
                    )
                  ]),
      ),
    );
  }

  Widget _statTile(String title, dynamic value) {
    return Card(
      color: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value == null ? '—' : value.toString(), style: const TextStyle(fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}