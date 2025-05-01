import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
//import 'community_notes.dart';
//import 'profile.dart';
//import 'theme_settings.dart';
//import 'postcard_maker.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WeatherlyApp());
}

class WeatherlyApp extends StatelessWidget {
  const WeatherlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
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
                "“Wherever you go, no matter what the weather, always bring your own sunshine.”",
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
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weatherly Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${user?.email ?? "User"}!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WeatherScreen()),
                );
              },
              child: const Text("Weather Forecast"),
            ),
            ElevatedButton(
              onPressed: () {}, // TODO: Go to Map screen
              child: const Text("View Map"),
            ),


/*
          ElevatedButton.icon(
            icon: const Icon(Icons.post_add),
           label: const Text("Make a Postcard"),
            onPressed: () {
           Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => const PostcardMakerScreen(),
          ),
        );
      },
    ),
*/
            ElevatedButton(
              onPressed: () {}, // TODO: Go to Postcard Maker
              child: const Text("Create Postcard"),
            ),

            /*
            ElevatedButton(
            onPressed: () {
             Navigator.of(context).push(
             MaterialPageRoute(builder: (_) => const CommunityNotesScreen()),
             );
             },
            child: const Text("Community Notes"),
            ),
            */

           /*
           ElevatedButton(
            onPressed: () {
            Navigator.of(context).push(
             MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            },
            child: const Text("Profile"),
            ),
           */

            ElevatedButton(
              onPressed: () {}, // TODO: Go to Theme settings
              child: const Text("Theme Settings"),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Forecast")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "Enter city",
                border: OutlineInputBorder(),
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
            ConstrainedBox(
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
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day["day"]!, style: const TextStyle(fontSize: 16)),
                        Text(day["icon"]!, style: const TextStyle(fontSize: 28)),
                        Text(day["temp"]!, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                },
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
            ConstrainedBox(
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
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(hour["hour"]!, style: const TextStyle(fontSize: 14)),
                        Text(hour["icon"]!, style: const TextStyle(fontSize: 24)),
                        Text(hour["temp"]!, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                },
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Feels Like: $feelsLike"),
                        Text("Humidity: $humidity"),
                        Text("Wind: $wind"),
                        Text("Pressure: $pressure"),
                        Text("Visibility: $visibility"),
                        Text("Sunrise: $sunrise"),
                        Text("Sunset: $sunset"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}