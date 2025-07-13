import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/user_model.dart';
import '../../../services/http_client_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:convert';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final HttpClientService httpClient = HttpClientService();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
  }

  void _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await httpClient.post("auth/login", {
        "email": event.email, // backend kamu pakai "username" sebagai field
        "password": event.password,
      });

      final json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(json['user']);
        await httpClient.saveTokenAndUser(json['token'], json['user']);
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure(json['message']));
      }
    } catch (e) {
      emit(AuthFailure("Terjadi kesalahan: $e"));
    }
  }

  void _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await httpClient.post("auth/register", {
        "username": event.username,
        "email": event.email,
        "password": event.password,
        "role": event.role,
      });

      final json = jsonDecode(response.body);
      if (response.statusCode == 201) {
        emit(AuthInitial()); // Sukses daftar, bisa redirect ke login
      } else {
        emit(AuthFailure(json['message']));
      }
    } catch (e) {
      emit(AuthFailure("Terjadi kesalahan: $e"));
    }
  }
}
