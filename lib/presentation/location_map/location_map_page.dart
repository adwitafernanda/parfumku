import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../../data/model/location_model.dart';
import 'bloc/location_bloc.dart';
import 'bloc/location_event.dart';
import 'bloc/location_state.dart';

class LocationMapPage extends StatefulWidget {
  const LocationMapPage({super.key});

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  LatLng? _selectedLatLng;
  String _selectedPlaceName = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(FetchLocations());
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateMarkers(List<LocationModel> locations) {
    setState(() {
      _markers = locations.map((location) {
        return Marker(
          markerId: MarkerId(location.id.toString()),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.description,
          ),
        );
      }).toSet();
    });
  }

  void _onMapTap(LatLng latLng) async {
    List<geo.Placemark> placemarks =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    String name = placemarks.isNotEmpty
        ? placemarks.first.name ?? "Lokasi tanpa nama"
        : "Lokasi tidak dikenal";

    setState(() {
      _selectedLatLng = latLng;
      _selectedPlaceName = name;
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: latLng,
          infoWindow: InfoWindow(title: name),
        ),
      );
    });
  }

  void _onSearchPlace() async {
    String address = _searchController.text;
    if (address.isEmpty) return;

    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        mapController?.animateCamera(CameraUpdate.newLatLng(latLng));

        setState(() {
          _selectedLatLng = latLng;
          _selectedPlaceName = address;
          _markers.add(
            Marker(
              markerId: const MarkerId('searched'),
              position: latLng,
              infoWindow: InfoWindow(title: address),
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tempat tidak ditemukan")),
      );
    }
  }

  void _submitLocation() {
    if (_selectedLatLng == null) return;

    final newLocation = LocationModel(
      id: 0,
      name: _selectedPlaceName,
      description: 'Ditambahkan manual',
      latitude: _selectedLatLng!.latitude,
      longitude: _selectedLatLng!.longitude,
      createdAt: DateTime.now(),
    );

    context.read<LocationBloc>().add(AddLocation(newLocation));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lokasi berhasil ditambahkan")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Lokasi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama tempat...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearchPlace,
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded) {
            _updateMarkers(state.locations);
          }
        },
        builder: (context, state) {
          return GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-7.7956, 110.3695),
              zoom: 12.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
      floatingActionButton: _selectedLatLng != null
          ? FloatingActionButton.extended(
              onPressed: _submitLocation,
              label: const Text("Simpan Lokasi"),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }
}
