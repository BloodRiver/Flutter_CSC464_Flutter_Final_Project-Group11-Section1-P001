import 'package:ai_language_tutor/screens/register.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Welcome to AI Language Tutor",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
                Text("Email", style: TextStyle(fontSize: 16)),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextField(),
                ),
                Text("Password", style: TextStyle(fontSize: 16)),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextField(obscureText: true),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: FilledButton(
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16,
                      ),
                      child: Text(
                        "Sign In",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<RegisterScreen>(
                        builder: (_) => RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Click here to Register",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
