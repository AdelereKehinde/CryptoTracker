import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = FlutterSecureStorage();
  bool _loading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // Step 1: Create account
      final signupResponse = await Dio().post(
        'https://cryptotracker-yof6.onrender.com/signup',
        data: {
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "country": _countryController.text.trim(),
          "password": _passwordController.text.trim(),
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
          responseType: ResponseType.json,
        ),
      );

      if (signupResponse.statusCode != 200) {
        throw Exception("Signup failed");
      }

      // Step 2: Auto-login after signup
      final loginResponse = await Dio().post(
        'https://cryptotracker-yof6.onrender.com/token',
        data: {
          "username": _usernameController.text.trim(),
          "password": _passwordController.text.trim(),
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
          responseType: ResponseType.json,
        ),
      );

      if (loginResponse.statusCode == 200) {
        final token = loginResponse.data['access_token'];
        await _storage.write(key: 'auth_token', value: token);

        Fluttertoast.showToast(
          msg: "Account created & logged in!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        // Go straight to home
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        throw Exception("Auto-login failed");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Signup failed. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Create Account"),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Container(
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blue[50]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.orange[100],
                        child: Icon(
                          Icons.currency_bitcoin,
                          size: 56,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Join Cheese Ball Crypto",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "Track coins, build wealth",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person_outline, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? "Username required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (v) => v == null || !v.contains('@') ? "Valid email required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          hintText: "+1234567890",
                          prefixIcon: Icon(Icons.phone_android, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (v) => v == null || v.trim().length < 10 ? "Valid phone required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Country
                      TextFormField(
                        controller: _countryController,
                        decoration: InputDecoration(
                          labelText: "Country",
                          prefixIcon: Icon(Icons.public, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? "Country required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                        validator: (v) => v == null || v.length < 6 ? "6+ characters required" : null,
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      _loading
                          ? CircularProgressIndicator(color: Colors.blue[700])
                          : SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  elevation: 6,
                                  shadowColor: Colors.blue[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: Icon(Icons.person_add_alt_1, color: Colors.white, size: 28),
                                label: Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 20),

                      // Login Link
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            children: [
                              TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Login here",
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}