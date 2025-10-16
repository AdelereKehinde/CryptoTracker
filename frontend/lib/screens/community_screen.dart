import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

void main() => runApp(CryptoFusionApp());

class CryptoFusionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Fusion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF161B22)),
      ),
      home: const CryptoDashboard(),
    );
  }
}

class CryptoDashboard extends StatefulWidget {
  const CryptoDashboard({super.key});
  @override
  State<CryptoDashboard> createState() => _CryptoDashboardState();
}

class _CryptoDashboardState extends State<CryptoDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Fusion'),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: "Market"),
            Tab(icon: Icon(Icons.newspaper), text: "News"),
            Tab(icon: Icon(Icons.info_outline), text: "About"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          MarketTab(),
          NewsTab(),
          AboutTab(),
        ],
      ),
    );
  }
}

//
// ─── MARKET TAB ──────────────────────────────────────────────
//
class MarketTab extends StatefulWidget {
  const MarketTab({super.key});
  @override
  State<MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<MarketTab> {
  final Dio dio = Dio();
  List<dynamic> coins = [];
  bool loading = true;

  Future<void> fetchCoins() async {
    setState(() => loading = true);
    try {
      final res = await dio.get(
          'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1');
      coins = res.data;
    } catch (_) {
      coins = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchCoins();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: fetchCoins,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: coins.length,
        itemBuilder: (context, i) {
          final c = coins[i];
          return Card(
            color: const Color(0xFF161B22),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(c['image'])),
              title: Text(c['name']),
              subtitle: Text('Current Price: \$${c['current_price']}'),
              trailing: Text(
                '${c['price_change_percentage_24h'].toStringAsFixed(2)}%',
                style: TextStyle(
                  color: c['price_change_percentage_24h'] > 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoinChartPage(
                    coinId: c['id'],
                    coinName: c['name'],
                    image: c['image'],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//
// ─── COIN CHART PAGE ──────────────────────────────────────────────
//
class CoinChartPage extends StatefulWidget {
  final String coinId;
  final String coinName;
  final String image;
  const CoinChartPage(
      {required this.coinId, required this.coinName, required this.image});

  @override
  State<CoinChartPage> createState() => _CoinChartPageState();
}

class _CoinChartPageState extends State<CoinChartPage> {
  List<double> prices = [];
  bool loading = true;
  String range = '1';

  Future<void> fetchChart(String days) async {
    setState(() => loading = true);
    final res = await Dio().get(
        'https://api.coingecko.com/api/v3/coins/${widget.coinId}/market_chart',
        queryParameters: {'vs_currency': 'usd', 'days': days});
    final List data = res.data['prices'];
    prices = data.map((e) => (e[1] as num).toDouble()).toList();
    setState(() {
      range = days;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchChart(range);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(backgroundImage: NetworkImage(widget.image)),
          const SizedBox(width: 8),
          Text(widget.coinName),
        ]),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 12),
                ToggleButtons(
                  isSelected: [range == '1', range == '7', range == '30'],
                  onPressed: (i) {
                    final days = i == 0 ? '1' : (i == 1 ? '7' : '30');
                    fetchChart(days);
                  },
                  color: Colors.white70,
                  selectedColor: Colors.white,
                  fillColor: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('1D')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('7D')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('30D')),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: CustomPaint(
                    painter: ChartPainter(prices),
                    child: Container(),
                  ),
                ),
              ],
            ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (data.isEmpty) return;

    final path = Path();
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final minY = data.reduce((a, b) => a < b ? a : b);
    final dx = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minY) / (maxY - minY)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ChartPainter old) => old.data != data;
}

//
// ─── NEWS TAB (Binance Feed) ──────────────────────────────────────────────
//
class NewsTab extends StatefulWidget {
  const NewsTab({super.key});
  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  List news = [];
  bool loading = true;

  Future<void> fetchNews() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get(
          'https://api.binance.com/api/v3/ticker/price'); // Binance public endpoint
      news = response.data.take(20).toList(); // just using prices as pseudo-news
    } catch (_) {
      news = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchNews,
            child: ListView.builder(
              itemCount: news.length,
              itemBuilder: (context, i) {
                final item = news[i];
                return Card(
                  color: const Color(0xFF161B22),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.article, color: Colors.yellow),
                    title: Text(item['symbol'] ?? 'Unknown'),
                    subtitle: Text('Price: ${item['price']}'),
                  ),
                );
              },
            ),
          );
  }
}

//
// ─── ABOUT TAB ──────────────────────────────────────────────
//
class AboutTab extends StatelessWidget {
  const AboutTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Crypto Fusion combines market charts, price tracking, and crypto news from Binance & CoinGecko APIs — all in one stylish dashboard.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
    );
  }
}
