import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taste_guide_app/recipe_selector_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecipeSelectorPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black, // Başlık arka planı siyah
          centerTitle: true,
        ),
        body: Stack(
            children: [
              // Arka plan görseli
              Positioned.fill(
                child: Image.asset(
                  'assets/image.jpeg.jpg', // Resim dosyasının yolunu buraya yazın
                  fit: BoxFit.cover,
                ),
              ),
              // İçerik
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Email giriş kutusu
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8), // Beyaz ve hafif şeffaf
                            borderRadius: BorderRadius.circular(12), // Köşeleri yuvarlak
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Şifre giriş kutusu
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8), // Beyaz ve hafif şeffaf
                            borderRadius: BorderRadius.circular(12), // Köşeleri yuvarlak
                          ),
                          child: TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              labelText: 'Password',
                            ),
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Login butonu
                        ElevatedButton(
                          onPressed: _login,
                          child: const Text('Login', style: TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(height: 10),
                        // Register butonu
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text('Register', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            ),
        );
    }
}