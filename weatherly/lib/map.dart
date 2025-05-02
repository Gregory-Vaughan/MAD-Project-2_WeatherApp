import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Map")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(32.7767, -96.7970), // Dallas, TX
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.weatherly',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(32.7767, -96.7970),
                width: 80,
                height: 80,
                child: const Icon(Icons.cloud, size: 40, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
