import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/map_error_banner.dart';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  static const LatLng _tunisiaCenter = LatLng(35.0, 10.0);
  static const CameraPosition _initialPosition = CameraPosition(
    target: _tunisiaCenter,
    zoom: 6,
  );
  static const String _mapsApiKey =
      String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  Set<Marker> get _markers => _selectedLocation == null
      ? <Marker>{}
      : {
          Marker(
            markerId: const MarkerId('selected-location'),
            position: _selectedLocation!,
          ),
        };

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
      ),
      body: Column(
        children: [
          if (_mapsApiKey.isEmpty)
            const MapErrorBanner(
              message: 'Maps API key missing. Set MAPS_API_KEY in local.properties.',
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (position) {
                setState(() {
                  _selectedLocation = position;
                });
              },
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _useCurrentLocation,
                  child: const Text('Use my current location'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _confirmLocation,
                  child: const Text('Confirm location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled.');
      return;
    }

    var permission = await Permission.locationWhenInUse.status;
    if (!permission.isGranted) {
      permission = await Permission.locationWhenInUse.request();
    }

    if (!permission.isGranted) {
      _showSnackBar('Location permission denied.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = latLng;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 16),
      );
    } catch (error) {
      _showSnackBar('Unable to fetch current location.');
    }
  }

  void _confirmLocation() {
    if (_selectedLocation == null) {
      _showSnackBar('Tap the map to drop a pin first.');
      return;
    }
    Navigator.of(context).pop(_selectedLocation);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
