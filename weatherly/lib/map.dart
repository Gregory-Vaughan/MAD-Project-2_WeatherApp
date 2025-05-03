import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class WeatherMarker extends Marker {
  final String condition;

  WeatherMarker({
    required this.condition,
    required super.point,
    required super.width,
    required super.height,
    required super.child,
    super.alignment = Alignment.center,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();
  final String _apiKey = 'ff357a23038b33c7a1e77df3acbac565'; // Replace with your OpenWeatherMap API key

  List<WeatherMarker> _allMarkers = [];
  List<WeatherMarker> _filteredMarkers = [];
  String _selectedCondition = 'All';

  LatLng _mapCenter = LatLng(39.8283, -98.5795);
  double _mapZoom = 4.0;

  Future<void> _searchCity(String cityName) async {
    final String geocodingUrl =
        'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$_apiKey';

    try {
      final response = await http.get(Uri.parse(geocodingUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final double lat = data[0]['lat'];
          final double lon = data[0]['lon'];

          final weatherData = await _fetchWeather(lat, lon);
          if (weatherData != null) {
            final String condition = weatherData['weather'][0]['main'];
            final String icon = weatherData['weather'][0]['icon'];
            final int temp = (weatherData['main']['temp'] - 273.15).round(); // Kelvin to Celsius
            final String emoji = _getEmojiFromIcon(icon);

            _mapController.move(LatLng(lat, lon), 10.0);

            final marker = WeatherMarker(
              condition: condition,
              point: LatLng(lat, lon),
              width: 120,
              height: 100,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$temp°C $emoji',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.red,
                  ),
                ],
              ),
            );

            setState(() {
              _allMarkers.add(marker);
              _applyFilter();
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('City not found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching city data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchWeather(double lat, double lon) async {
    final String weatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey';

    try {
      final response = await http.get(Uri.parse(weatherUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _getEmojiFromIcon(String iconCode) {
    if (iconCode.contains('d')) {
      return {
        "01d": "☀️",
        "02d": "🌤️",
        "03d": "🌥️",
        "04d": "☁️",
        "09d": "🌧️",
        "10d": "🌦️",
        "11d": "⛈️",
        "13d": "❄️",
        "50d": "🌫️",
      }[iconCode] ?? "🌈";
    } else {
      return {
        "01n": "🌙",
        "02n": "☁️",
        "03n": "🌥️",
        "04n": "☁️",
        "09n": "🌧️",
        "10n": "🌧️",
        "11n": "⛈️",
        "13n": "❄️",
        "50n": "🌫️",
      }[iconCode] ?? "🌈";
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedCondition == 'All') {
        _filteredMarkers = List.from(_allMarkers);
      } else {
        _filteredMarkers = _allMarkers
            .where((marker) => marker.condition.toLowerCase() == _selectedCondition.toLowerCase())
            .toList();
      }
    });
  }

  void _zoomIn() {
    setState(() {
      _mapZoom += 1;
      _mapController.move(_mapCenter, _mapZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _mapZoom -= 1;
      _mapController.move(_mapCenter, _mapZoom);
    });
  }

  Widget _buildFilterButton(String condition) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCondition = condition;
            _applyFilter();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedCondition == condition
              ? Colors.blueAccent
              : Colors.grey[400],
        ),
        child: Text(condition),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Map'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    String cityName = _cityController.text.trim();
                    if (cityName.isNotEmpty) {
                      _searchCity(cityName);
                    }
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton('All'),
                _buildFilterButton('Clear'),
                _buildFilterButton('Clouds'),
                _buildFilterButton('Rain'),
                _buildFilterButton('Snow'),
                _buildFilterButton('Thunderstorm'),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: _mapZoom,
                    onPositionChanged: (position, hasGesture) {
                      if (position.center != null && position.zoom != null) {
                        setState(() {
                          _mapCenter = position.center!;
                          _mapZoom = position.zoom!;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: _filteredMarkers,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        mini: true,
                        onPressed: _zoomIn,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        mini: true,
                        onPressed: _zoomOut,
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
