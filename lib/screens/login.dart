import 'package:ai_language_tutor/input_widgets/input_fields.dart';
import 'package:ai_language_tutor/models.dart';
import 'package:ai_language_tutor/screens/mainscreen.dart';
import 'package:ai_language_tutor/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.clear();
    _passwordController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Text(
                      "Welcome to AI Language Tutor",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Text("Email", style: TextStyle(fontSize: 16)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: EmailInputField(controller: _emailController),
                  ),
                  Text("Password", style: TextStyle(fontSize: 16)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: PasswordInputField(controller: _passwordController),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          User? currentUser = await User.findUserByEmail(
                            email: _emailController.text.trim(),
                          );

                          if (currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "User does not exist",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (!currentUser.checkPassword(
                            _passwordController.text,
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Incorrect Password",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          _emailController.clear();
                          _passwordController.clear();
                          await currentUser.updateLogin();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Login Success",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Get.put<User>(currentUser);
                          Navigator.of(context).push(
                            MaterialPageRoute<MainScreen>(
                              builder: (_) => MainScreen(),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16,
                        ),
                        child: Text(
                          "Login",
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
      ),
    );
  }
}
