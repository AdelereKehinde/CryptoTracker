// Blockchain Explorer Screen
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
class BlockchainExplorerScreen extends StatefulWidget {
  @override
  State<BlockchainExplorerScreen> createState() => _BlockchainExplorerScreenState();
}

class _BlockchainExplorerScreenState extends State<BlockchainExplorerScreen> {
  List chains = [];
  bool loading = true;

  Future<void> fetchChains() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('http://localhost:8000/blockchains');
      chains = response.data['chains'] ?? [];
    } catch (e) {
      chains = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchChains();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blockchain Explorer'), backgroundColor: Colors.blue[900]),
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
                itemCount: chains.length,
                itemBuilder: (context, i) {
                  final chain = chains[i];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.link, color: Colors.blue),
                      title: Text(chain['name'] ?? ''),
                      subtitle: Text('Height: ${chain['height'] ?? ''}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
