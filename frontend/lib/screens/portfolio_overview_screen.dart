import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PortfolioOverviewScreen extends StatefulWidget {
  const PortfolioOverviewScreen({super.key});

  @override
  State<PortfolioOverviewScreen> createState() => _PortfolioOverviewScreenState();
}

class _PortfolioOverviewScreenState extends State<PortfolioOverviewScreen> {
  List holdings = [];
  bool loading = true;

  Future<void> fetchPortfolio() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('https://cryptotracker-yof6.onrender.com/portfolio');
      holdings = response.data['portfolio'];
    } catch (e) {
      holdings = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/add_holding');
              fetchPortfolio();
            },
          )
        ],
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
            : holdings.isEmpty
                ? Center(child: Text('No holdings yet.', style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: holdings.length,
                    itemBuilder: (context, i) {
                      final h = holdings[i];
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.currency_bitcoin, color: Colors.orange, size: 32),
                          title: Text('${h['coin']}'),
                          subtitle: Text('Amount: ${h['amount']}'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}