import 'package:equatable/equatable.dart';
import '../../../data/model/location_model.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final List<LocationModel> locations;

  const LocationLoaded({required this.locations});

  @override
  List<Object> get props => [locations];
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object> get props => [message];
}