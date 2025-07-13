import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parfumku/data/repository/location_repository.dart';
import 'package:parfumku/presentation/location_map/bloc/location_bloc.dart';
import 'data/repository/parfum_repository.dart'; // Import repository
import 'package:parfumku/presentation/parfum/bloc/parfum_bloc.dart';
import 'package:parfumku/services/http_client_service.dart'; // Import HttpClientService
import 'routes/app_routes.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/location_map/bloc/location_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final HttpClientService _httpClientService = HttpClientService();
  final ParfumRepository _parfumRepository;

  MyApp({super.key}) : _parfumRepository = ParfumRepository(); // Inisialisasi repository

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider( // Tambahkan ParfumBloc
          create: (_) => ParfumBloc(parfumRepository: _parfumRepository),
        ),
        BlocProvider<LocationBloc>( // Tambahkan BlocProvider untuk LocationBloc
          create: (context) => LocationBloc(
            locationRepository: LocationRepository(), // Inisialisasi repository lokasi
          ),
        ),
        
      ],
      child: MaterialApp(
        title: 'ParfumKu',
        theme: ThemeData(primarySwatch: Colors.purple),
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: "/",
      ),
    );
  }
}