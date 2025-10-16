// Category Explorer Screen
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
class CategoryExplorerScreen extends StatefulWidget {
  @override
  State<CategoryExplorerScreen> createState() => _CategoryExplorerScreenState();
}

class _CategoryExplorerScreenState extends State<CategoryExplorerScreen> {
  List categories = [];
  bool loading = true;

  Future<void> fetchCategories() async {
    setState(() => loading = true);
    try {
      final response = await Dio().get('http://localhost:8000/coins/categories/list');
      categories = response.data ?? [];
    } catch (e) {
      categories = [];
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories'), backgroundColor: Colors.blue[900]),
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
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.category, color: Colors.blue),
                      title: Text(cat['name'] ?? ''),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
