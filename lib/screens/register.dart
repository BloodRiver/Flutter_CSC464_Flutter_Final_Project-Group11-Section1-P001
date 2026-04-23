import "package:ai_language_tutor/input_widgets/input_fields.dart";
import "package:ai_language_tutor/models.dart";
import "package:flutter/material.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypeController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypeController.dispose();
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
                      "Create an Account for AI Language Tutor",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      spacing: 15,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "First Name",
                                style: TextStyle(fontSize: 16),
                              ),
                              SingleLineTextInputField(
                                controller: _firstNameController,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text("Last Name", style: TextStyle(fontSize: 16)),
                              SingleLineTextInputField(
                                controller: _lastNameController,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  Text("Re-Type Password", style: TextStyle(fontSize: 16)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: PasswordInputField(controller: _retypeController),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_retypeController.text !=
                              _passwordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error: The Passwords do not match",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            User newUser = User.create(
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            );

                            try {
                              await newUser.saveNew();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Registration Success",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.of(context).pop();
                            } catch (userSaveError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Registration Error: ${userSaveError.toString()}",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              print(userSaveError.toString());
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please correct above errors",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
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
                          "Register",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Already have an account? Click here to Login",
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
