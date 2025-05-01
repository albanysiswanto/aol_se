class RegisterRequest {
  final String birth_date;
  final String email;
  final String full_name;
  final String password;
  final String? invite_token;

  RegisterRequest({
    required this.birth_date,
    required this.email,
    required this.full_name,
    required this.password,
    this.invite_token,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'birth_date': birth_date,
      'email': email,
      'full_name': full_name,
      'password': password,
      if (invite_token?.isNotEmpty ?? false) 'invite_token': invite_token,
    };

    return data;
  }
}
