import 'package:flutter/material.dart';
import 'package:disciplined_coach/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disiplinli Koç Giriş'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                validator: (val) => val!.isEmpty ? 'Email girin' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Şifre 6+ karakter olmalı' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
                decoration: const InputDecoration(
                  hintText: 'Şifre',
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                child: const Text('Giriş Yap'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if (result == null) {
                      setState(() => error = 'Giriş yapılamadı. Bilgileri kontrol edin.');
                    }
                  }
                },
              ),
              const SizedBox(height: 12.0),
              ElevatedButton(
                child: const Text('Kayıt Ol'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                    if (result == null) {
                      setState(() => error = 'Kayıt başarısız. Lütfen tekrar deneyin.');
                    }
                  }
                },
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
