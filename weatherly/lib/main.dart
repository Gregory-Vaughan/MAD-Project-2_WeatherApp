import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'community_notes.dart';
import 'profile.dart';
import 'postcard_maker.dart';
import 'map.dart'; // for new map screen
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'theme_settings.dart'; // Adjust path if needed




final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);



//changed main app to fit theme settings better. May want to change it back to the original if this messes something up.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WeatherlyRoot());
}


class WeatherlyRoot extends StatelessWidget {
  const WeatherlyRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Weatherly',
          debugShowCheckedModeBanner: false,
          
          theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF8F9FC), // soft off-white
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE3F2FD), // light sky blue tone
            foregroundColor: Colors.black87,
            elevation: 2,
          ),
          cardColor: const Color(0xFFFFFFFF), // bright for content blocks
          dialogBackgroundColor: const Color(0xFFFFFFFF),
          colorScheme: ColorScheme.light(
            primary: Colors.blueAccent,
            secondary: Colors.lightBlueAccent,
            surface: Colors.white,
          ),
          textTheme: ThemeData.light().textTheme.apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black87,
              ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ),

          
          darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1F1F2E), // softened dark
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2C2C3E), // slightly lighter for contrast
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardColor: const Color(0xFF2A2A3A),
          dialogBackgroundColor: const Color(0xFF2A2A3A),
          colorScheme: ColorScheme.dark(
            primary: Colors.blueAccent,
            secondary: Colors.lightBlueAccent,
            surface: const Color(0xFF2A2A3A),
          ),
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Colors.white.withOpacity(0.9),
                displayColor: Colors.white,
              ),
        ),

          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueAccent,
        child: const Center(
          child: Text(
            'Weatherly',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------LOGIN SCREEN---------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Text(
                "Weatherly",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "“Wherever you go, no matter the weather, always bring your own sunshine, to make the day better.”",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      child: const Text("Login"),
                    ), 
              TextButton(
                onPressed: goToRegister,
                child: const Text("Don't have an account? Register here."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------REGISTER SCREEN---------------------------------------

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

Future<void> register() async {
  if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  try {
    setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // ✅ Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration successful")),
    );

    // ✅ Wait briefly so user sees the message
    await Future.delayed(const Duration(seconds: 1));

    // ✅ Then return to Login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "Registration failed")),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  void goToLogin() {
    Navigator.of(context).pop(); // Just pop back to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm Password"),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: register,
                      child: const Text("Register"),
                    ),
              TextButton(
                onPressed: goToLogin,
                child: const Text("Already have an account? Login here."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ---------------------------------------HOME SCREEN---------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _weatherInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocationWeather();
  }

  Future<void> _fetchCurrentLocationWeather() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _weatherInfo = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _weatherInfo = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _weatherInfo = 'Location permissions are permanently denied.';
          _isLoading = false;
        });
        return;
      }

      // Get current position with a timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      // Fetch weather data
      const String apiKey = 'ff357a23038b33c7a1e77df3acbac565';
      final String apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String cityName = data['name'];
        final double temperature = data['main']['temp'];
        final String description = data['weather'][0]['description'];
        final String iconCode = data['weather'][0]['icon'];
        final String emoji = _mapWeatherIconToEmoji(iconCode);

        setState(() {
          _weatherInfo =
              '$emoji  City: $cityName\n${temperature.toStringAsFixed(1)}°C, $description';
          _isLoading = false;
        });
      } else {
        setState(() {
          _weatherInfo = 'Failed to fetch weather data.';
          _isLoading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        _weatherInfo = 'Request timed out. Please try again.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _mapWeatherIconToEmoji(String iconCode) {
    switch (iconCode) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
      case '02n':
        return '🌤️';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌈';
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        elevation: 3,
        backgroundColor: Colors.blueGrey[50],
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.blue),
          const SizedBox(height: 12),
          Text(label,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "User";

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final weatherTextColor = isDarkMode ? Colors.black87 : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Row(
        children: const [
          Icon(Icons.cloud, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text(
            'Weatherly Dashboard',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome, $displayName!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Your Current Location Weather',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: weatherTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _weatherInfo?.split('\n').first ?? '',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: weatherTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _weatherInfo?.split('\n').last ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: weatherTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildDashboardButton(
                    context,
                    icon: Icons.cloud,
                    label: "Weather Forecast",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WeatherScreen()),
                      );
                    },
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.map,
                    label: "View Map",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapScreen()),
                      );
                    },
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.notes,
                    label: "Community Notes",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CommunityNotesScreen()),
                      );
                    },
                  ),

                  _buildDashboardButton(
                    context,
                    icon: Icons.card_giftcard,
                    label: "Create Postcard",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PostcardMakerScreen()),
                      );
                    },
                  ),

                  _buildDashboardButton(
                    context,
                    icon: Icons.person,
                    label: "Profile",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.settings,
                    label: "Theme Settings",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}


// ---------------------------------------WEATHER FORECAST SCREEN---------------------------------------

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController();
  bool isLoading = false;

  String city = "New York";
  String temperature = "";
  String condition = "";
  String feelsLike = "";
  String humidity = "";
  String wind = "";
  String pressure = "";
  String visibility = "";
  String sunrise = "";
  String sunset = "";
  String currentIcon = "";
  String currentHourlyIcon = "";
  List<Map<String, String>> forecast = [];
  List<Map<String, String>> hourlyForecast = [];

  final String apiKey = "ff357a23038b33c7a1e77df3acbac565"; // Replace with your real API key

  Future<void> _loadCityFromFirestore() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final savedCity = doc.data()?['city'];

  if (savedCity != null && savedCity.toString().isNotEmpty) {
    cityController.text = savedCity;
    await getWeather(); // Automatically fetch weather
  }
}

  Future<void> getWeather() async {
    final enteredCity = cityController.text.trim();
    if (enteredCity.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final urlCurrent = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$enteredCity&appid=$apiKey&units=metric");
      final urlForecast = Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$enteredCity&appid=$apiKey&units=metric");

      final responseCurrent = await http.get(urlCurrent);
      final responseForecast = await http.get(urlForecast);

      print('Current weather response: ${responseCurrent.body}');
      print('Forecast response: ${responseForecast.body}');

      if (responseCurrent.statusCode == 200 && responseForecast.statusCode == 200) {
        final currentData = json.decode(responseCurrent.body);
        final forecastData = json.decode(responseForecast.body);

        List<Map<String, String>> daily = [];
        List<Map<String, String>> hourly = [];

        // Daily forecast - every 8 entries (3h x 8 = 24h)
        for (int i = 0; i < forecastData["list"].length; i += 8) {
          final entry = forecastData["list"][i];
          daily.add({
            "day": getDayFromTimestamp(entry["dt"]),
            "temp": "${entry["main"]["temp"].round()}°C",
            "icon": getEmojiFromIconCode(entry["weather"][0]["icon"]),
          });
        }
// Hourly forecast - next 8 slots (3h intervals = 24h)
        for (int i = 0; i < 8; i++) {
          final entry = forecastData["list"][i];
          final time = DateTime.fromMillisecondsSinceEpoch(entry["dt"] * 1000);
          final hour = DateFormat('HH:mm').format(time); // or 'h a' for 12-hour format
          hourly.add({
            "hour": DateFormat('h a').format(time), // gives "11 PM", "2 AM", etc.
            "temp": "${entry["main"]["temp"].round()}°C",
            "icon": getEmojiFromIconCode(entry["weather"][0]["icon"]),
          });
        }
        
        if (hourly.isNotEmpty) {
          currentHourlyIcon = hourly[0]["icon"] ?? "";
        }


        setState(() {
          city = currentData["name"];
          temperature = "${currentData["main"]["temp"].round()}°C";
          condition = currentData["weather"][0]["description"];
          currentIcon = currentData["weather"][0]["icon"]; 
          forecast = daily;
          hourlyForecast = hourly;
          feelsLike = "${currentData["main"]["feels_like"].round()}°C";
          humidity = "${currentData["main"]["humidity"]}%";
          wind = "${currentData["wind"]["speed"]} m/s ${_getDirection(currentData["wind"]["deg"])}";
          pressure = "${currentData["main"]["pressure"]} hPa";
          visibility = "${(currentData["visibility"] / 1000).toStringAsFixed(1)} km";

          sunrise = _formatTime(currentData["sys"]["sunrise"]);
          sunset = _formatTime(currentData["sys"]["sunset"]);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching weather data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.jm().format(time); // 5:30 AM, 7:15 PM
  }

  String _getDirection(num deg) {
    const directions = [
      "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"
    ];
    return directions[((deg % 360) / 45).round()];
  }
  
  String getDayFromTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7];
  }

  String getWeatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case "clear":
        return "☀️";
      case "clouds":
        return "☁️";
      case "rain":
        return "🌧️";
      case "snow":
        return "❄️";
      case "thunderstorm":
        return "⛈️";
      case "drizzle":
        return "🌦️";
      default:
        return "🌤️";
    }
  }

  String getEmojiFromIconCode(String iconCode) {
    switch (iconCode) {
      case "01d":
        return "☀️";
      case "01n":
        return "🌙";
      case "02d":
      case "02n":
        return "⛅";
      case "03d":
      case "03n":
      case "04d":
      case "04n":
        return "☁️";
      case "09d":
      case "09n":
      case "10d":
      case "10n":
        return "🌧️";
      case "11d":
      case "11n":
        return "⛈️";
      case "13d":
      case "13n":
        return "❄️";
      case "50d":
      case "50n":
        return "🌫️";
      default:
        return "🌤️";
    }
  }
  @override

  void initState() {
    super.initState();
    _loadCityFromFirestore();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    final isDarkMode = theme.brightness == Brightness.dark;
    final forecastTileColor = isDarkMode
        ? Colors.deepPurple.shade200.withOpacity(0.3)
        : Colors.lightGreen.shade200.withOpacity(0.4);

    return Scaffold(
      appBar: AppBar(title: const Text("Weather Forecast")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cityController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Enter city",
                labelStyle: TextStyle(color: textColor),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: getWeather,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Get Weather"),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Text(
                    city,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    temperature.isNotEmpty && condition.isNotEmpty
                        ? "$temperature | $condition"
                        : "No weather data",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "7-Day Forecast",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: forecast.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final day = forecast[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: forecastTileColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(day["day"]!, style: TextStyle(fontSize: 16, color: textColor)),
                          Text(day["icon"]!, style: const TextStyle(fontSize: 28)),
                          Text(day["temp"]!, style: TextStyle(fontSize: 16, color: textColor)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Hourly Forecast",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 110),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: hourlyForecast.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final hour = hourlyForecast[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: forecastTileColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(hour["hour"]!, style: TextStyle(fontSize: 14, color: textColor)),
                          Text(hour["icon"]!, style: const TextStyle(fontSize: 24)),
                          Text(hour["temp"]!, style: TextStyle(fontSize: 14, color: textColor)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Current Conditions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: forecastTileColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      currentHourlyIcon.isNotEmpty
                          ? currentHourlyIcon
                          : getWeatherEmoji(condition),
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Feels Like: $feelsLike", style: TextStyle(color: textColor)),
                        Text("Humidity: $humidity", style: TextStyle(color: textColor)),
                        Text("Wind: $wind", style: TextStyle(color: textColor)),
                        Text("Pressure: $pressure", style: TextStyle(color: textColor)),
                        Text("Visibility: $visibility", style: TextStyle(color: textColor)),
                        Text("Sunrise: $sunrise", style: TextStyle(color: textColor)),
                        Text("Sunset: $sunset", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}