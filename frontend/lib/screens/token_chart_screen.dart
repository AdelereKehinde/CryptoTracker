// Token Chart Screen
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TokenChartScreen extends StatefulWidget {
  @override
  State<TokenChartScreen> createState() => _TokenChartScreenState();
}

class _TokenChartScreenState extends State<TokenChartScreen> {
  List chartData = [];
  bool loading = true;

  Future<void> fetchChart(String id) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('http://localhost:8000/coins/$id/market_chart', queryParameters: {
        'vs_currency': 'usd',
        'days': '7',
      });
      chartData = response.data['prices'] ?? [];
    } catch (e) {
      chartData = [];
    }
    setState(() => loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String? ?? 'bitcoin';
    fetchChart(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Token Chart'), backgroundColor: Colors.blue[900]),
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
            : chartData.isEmpty
                ? Center(child: Text('No chart data', style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: chartData.length,
                    itemBuilder: (context, i) {
                      final point = chartData[i];
                      return ListTile(
                        title: Text('Time: ${DateTime.fromMillisecondsSinceEpoch(point[0].toInt())}'),
                        subtitle: Text('Price: \$${point[1]}'),
                      );
                    },
                  ),
      ),
    );
  }
}