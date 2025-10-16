// Add to Watchlist Modal
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddToWatchlistModal extends StatefulWidget {
  @override
  State<AddToWatchlistModal> createState() => _AddToWatchlistModalState();
}

class _AddToWatchlistModalState extends State<AddToWatchlistModal> {
  bool _loading = false;

  Future<void> _addToWatchlist(String coinId) async {
    setState(() => _loading = true);
    try {
      final response = await Dio().post('http://localhost:8000/watchlist/add', data: {'coin_id': coinId});
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Added to watchlist!", backgroundColor: Colors.blue);
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(msg: "Failed to add.", backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error adding to watchlist.", backgroundColor: Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinId = ModalRoute.of(context)!.settings.arguments as String? ?? 'bitcoin';
    return AlertDialog(
      title: Text('Add to Watchlist'),
      content: Text('Add this coin to your watchlist?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        _loading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _addToWatchlist(coinId),
                child: Text('Add'),
              ),
      ],
    );
  }
}
