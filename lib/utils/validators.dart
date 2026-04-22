class EmailValidator {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static String? validateFormat(String? email) {
    if ((email != null) && (_emailRegExp.hasMatch(email))) {
      return null;
    }

    return "Invalid Email Format";
  }
}

class PasswordValidator {
  static String? validateFormat(String? password) {
    String? errorCause;
    if (password == null) {
      errorCause = "Password must not be empty";
    } else if (password.length < 8) {
      errorCause = "Password must have at least 8 characters";
    }

    return errorCause;
  }
}
