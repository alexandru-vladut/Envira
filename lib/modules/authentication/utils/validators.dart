String? isTextValid(String? text) {

  if (text == null || text.isEmpty) {
    return 'Mandatory field.';
  }

  return null;
}

String? isEmailValid(String? email) {

  if (email == null || email.isEmpty) {
    return 'Mandatory field.';
  }

  RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    caseSensitive: false,
    multiLine: false,
  );

  if (!emailRegex.hasMatch(email)) {
    return 'Email format incorrect.';
  }

  return null;
}

String? isPasswordValid(String? password) {

  if (password == null || password.isEmpty) {
    return 'Mandatory field.';
  }

  if (password.length < 6) {
    return 'Password is too short.';
  }
  
  return null;
}

String? isConfirmPasswordValid(String? password, String? confirmPassword) {

  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Mandatory field.';
  }

  if (password != confirmPassword) {
    return 'Passwords do not match.';
  }

  return null;
}
