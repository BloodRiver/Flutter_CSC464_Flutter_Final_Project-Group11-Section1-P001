import 'package:ai_language_tutor/utils/validators.dart';
import 'package:flutter/material.dart';

class SingleLineTextInputField extends StatefulWidget {
  final TextEditingController controller;

  const SingleLineTextInputField({super.key, required this.controller});

  @override
  State<SingleLineTextInputField> createState() =>
      _SingleLineTextInputFieldState();
}

class _SingleLineTextInputFieldState extends State<SingleLineTextInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      maxLines: 1,
      keyboardType: TextInputType.text,
    );
  }
}

class EmailInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator = EmailValidator.validateFormat;

  const EmailInputField({super.key, required this.controller});

  @override
  State<EmailInputField> createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<EmailInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.text,
      maxLines: 1,
      validator: widget.validator,
    );
  }
}

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator = PasswordValidator.validateFormat;

  const PasswordInputField({super.key, required this.controller});

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: TextInputType.text,
      maxLines: 1,
      obscureText: true,
    );
  }
}
