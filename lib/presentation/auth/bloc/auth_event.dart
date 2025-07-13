
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String role;

  RegisterRequested(this.username, this.email, this.password, this.role);
}