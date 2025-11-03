import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PortfolioHistoryScreen extends StatefulWidget {
  const PortfolioHistoryScreen({super.key});

  @override
  State<PortfolioHistoryScreen> createState() => _PortfolioHistoryScreenState();
}

class _PortfolioHistoryScreenState extends State<PortfolioHistoryScreen> {
  List history = [];
  bool loading = true;

  Future<void> fetchHistory() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/portfolio/history');
      history = response.data['history'] ?? [];
    } catch (e) {
      history = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Portfolio History'), backgroundColor: Colors.blue[900]),
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
                itemCount: history.length,
                itemBuilder: (context, i) {
                  final h = history[i];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.history, color: Colors.blue),
                      title: Text('Date: ${h['date']}'),
                      subtitle: Text('Value: \$${h['value']}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}