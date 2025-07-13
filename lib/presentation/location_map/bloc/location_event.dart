import 'package:equatable/equatable.dart';
import 'package:parfumku/data/model/location_model.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class FetchLocations extends LocationEvent {}
// location_event.dart
class AddLocation extends LocationEvent {
  final LocationModel location;

  AddLocation(this.location);
}
