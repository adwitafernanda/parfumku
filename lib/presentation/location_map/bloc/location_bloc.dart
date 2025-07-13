import 'package:bloc/bloc.dart';
import 'package:parfumku/data/repository/location_repository.dart';
import 'package:parfumku/presentation/location_map/bloc/location_event.dart';
import 'package:parfumku/presentation/location_map/bloc/location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository locationRepository;

  LocationBloc({required this.locationRepository}) : super(LocationInitial()) {
    on<FetchLocations>(_onFetchLocations);
    on<AddLocation>(_onAddLocation); // ✅ sudah ditangani dengan method
  }

  void _onFetchLocations(FetchLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final locations = await locationRepository.fetchLocations();
      emit(LocationLoaded(locations: locations));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  void _onAddLocation(AddLocation event, Emitter<LocationState> emit) async {
    try {
      await locationRepository.addLocation(event.location); // Kirim ke database
      add(FetchLocations()); // Refresh data setelah tambah
    } catch (e) {
      emit(const LocationError(message: "Gagal menambahkan lokasi"));
    }
  }
}
