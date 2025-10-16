import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HomeDashboardScreen extends StatefulWidget {
  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List coins = [];
  bool loading = true;

  Future<void> fetchMarkets() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('http://localhost:8000/coins/markets');
      coins = response.data;
    } catch (e) {
      coins = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchMarkets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.currency_bitcoin, color: Colors.orange, size: 32),
            SizedBox(width: 8),
            Text('Cheese_Ball', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
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
            : RefreshIndicator(
                onRefresh: fetchMarkets,
                child: ListView.builder(
                  itemCount: coins.length,
                  itemBuilder: (context, i) {
                    final coin = coins[i];
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(coin['image'], width: 32),
                        title: Text('${coin['name']} (${coin['symbol'].toUpperCase()})'),
                        subtitle: Text('Price: \$${coin['current_price']}'),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
                        onTap: () {
                          Navigator.pushNamed(context, '/coin_detail', arguments: coin['id']);
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.pie_chart, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/portfolio'),
        tooltip: "Go to Portfolio",
      ),
    );
  }
}