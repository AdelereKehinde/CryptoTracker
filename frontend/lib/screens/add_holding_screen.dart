import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';

class AddHoldingScreen extends StatefulWidget {
  @override
  State<AddHoldingScreen> createState() => _AddHoldingScreenState();
}

class _AddHoldingScreenState extends State<AddHoldingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _coin = '';
  double _amount = 0.0;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ApiService.post('/portfolio', data: {
        'coin': _coin,
        'amount': _amount,
      });

      Fluttertoast.showToast(
        msg: "Holding added successfully!",
        backgroundColor: Colors.green,
      );

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to add holding",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Holding'), backgroundColor: Colors.blue[900]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.currency_bitcoin, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Coin Symbol (e.g. BTC)"),
                      onChanged: (v) => _coin = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter coin symbol" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Amount"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _amount = double.tryParse(v) ?? 0.0,
                      validator: (v) => v == null || double.tryParse(v) == null
                          ? "Enter amount"
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _loading
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Add Holding",
                                style: TextStyle(color: Colors.white)),
                            onPressed: _submit,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
