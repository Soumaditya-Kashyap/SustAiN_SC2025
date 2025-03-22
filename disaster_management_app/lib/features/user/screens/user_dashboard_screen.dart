import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/services/weather_service.dart';
import '../../shared/services/auth_service.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _weatherService = WeatherService();
  final _authService = AuthService();
  String _selectedLocation = AppConstants.predefinedLocations.keys.first;
  bool _isLoading = true;
  Map<String, dynamic>? _currentWeather;
  List<Map<String, dynamic>>? _forecast;
  List<Map<String, String>> _alerts = [
    {
      'title': 'Heavy Rainfall Alert',
      'description':
          'Heavy rainfall expected in Guwahati region. Stay indoors.',
      'severity': 'high',
    },
    {
      'title': 'Flood Warning',
      'description': 'Moderate flooding expected in low-lying areas of Howrah.',
      'severity': 'moderate',
    },
  ];
  List<String> _selectedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _loadUserData();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoading = true);

    try {
      final location = AppConstants.predefinedLocations[_selectedLocation]!;
      final weatherData = await _weatherService.getCurrentWeather(
        location['lat']!,
        location['lon']!,
      );
      final forecastData = await _weatherService.getForecast(
        location['lat']!,
        location['lon']!,
      );

      final processedWeather = _weatherService.processWeatherData(weatherData);
      final processedForecast =
          _weatherService.processForecastData(forecastData);

      setState(() {
        _currentWeather = processedWeather;
        _forecast = processedForecast;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading weather data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Failed to load weather data. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (userData != null && userData['selectedLocations'] != null) {
          setState(() {
            _selectedLocations =
                List<String>.from(userData['selectedLocations']);
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.profileRoute);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeatherData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Selector
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedLocation,
                      items: AppConstants.predefinedLocations.keys
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLocation = value);
                          _loadWeatherData();
                        }
                      },
                      underline: const SizedBox(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Current Weather
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_currentWeather != null)
                WeatherCard(
                  location: _selectedLocation,
                  temperature: _currentWeather!['temperature'] as double,
                  description: _currentWeather!['description'] as String,
                  iconUrl: _currentWeather!['icon'] as String,
                  humidity: _currentWeather!['humidity'] as double,
                  windSpeed: _currentWeather!['windSpeed'] as double,
                ),

              const SizedBox(height: 24),

              // Forecast
              if (_forecast != null && _forecast!.isNotEmpty) ...[
                Text(
                  '3-Day Forecast',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _forecast!.length,
                    itemBuilder: (context, index) {
                      final forecast = _forecast![index];
                      final date = forecast['date'] as DateTime;
                      final time = forecast['time'] as String;
                      final isEvening = time == 'evening';

                      // Get gradient colors based on weather description
                      List<Color> gradientColors = _getWeatherGradient(
                          forecast['description'] as String, isEvening);

                      return Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradientColors,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Time chip at the top
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isEvening
                                      ? Colors.deepPurple.withOpacity(0.7)
                                      : Colors.amber.withOpacity(0.7),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isEvening ? '5 PM' : '8 AM',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date
                                  Text(
                                    '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Temperature and icon
                                  Row(
                                    children: [
                                      Text(
                                        '${forecast['temperature'].round()}°',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Image.network(
                                          forecast['icon'] as String,
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Description
                                  Text(
                                    _capitalizeFirstLetter(
                                        forecast['description'] as String),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),

                                  // Humidity and wind
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.water_drop,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${forecast['humidity'].round()}%',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.air,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${forecast['windSpeed'].toStringAsFixed(1)} m/s',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Alerts Section
              Text(
                'Alerts & Warnings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (_selectedLocations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'No locations selected. Please update your profile with preferred locations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: _selectedLocations.map((location) {
                    final locationAlerts =
                        AppConstants.alertsByCity[location] ?? [];

                    // Sort alerts by timestamp (newest first)
                    locationAlerts.sort((a, b) => (b['timestamp'] as DateTime)
                        .compareTo(a['timestamp'] as DateTime));

                    return locationAlerts.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location Name Header
                              Container(
                                margin:
                                    const EdgeInsets.only(bottom: 8, top: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors:
                                        _getLocationHeaderGradient(location),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.warning_amber,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${locationAlerts.length}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Alerts Card
                              Container(
                                height: 200,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _getCityCardGradient(location),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    itemCount: locationAlerts.length,
                                    itemBuilder: (context, index) {
                                      final alert = locationAlerts[index];
                                      final isAlert = alert['type'] == 'alert';
                                      final timestamp =
                                          alert['timestamp'] as DateTime;
                                      final isToday = _isToday(timestamp);

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: _getAlertGradient(
                                                alert['severity'] as String,
                                                isAlert),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getShadowColor(
                                                  alert['severity'] as String,
                                                  isAlert),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              // Show more details in a dialog
                                              _showAlertDetails(
                                                  alert, location);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Padding(
                                              padding: const EdgeInsets.all(14),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      // Alert type icon with badge
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          isAlert
                                                              ? Icons
                                                                  .warning_amber
                                                              : Icons
                                                                  .info_outline,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 2,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: isAlert
                                                                        ? Colors
                                                                            .red
                                                                            .withOpacity(
                                                                                0.3)
                                                                        : Colors
                                                                            .blue
                                                                            .withOpacity(0.3),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Text(
                                                                    isAlert
                                                                        ? 'ALERT'
                                                                        : 'WARNING',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Text(
                                                                  isToday
                                                                      ? 'Today, ${_formatTime(timestamp)}'
                                                                      : '${_formatDate(timestamp)}, ${_formatTime(timestamp)}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.9),
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              alert['title']
                                                                  as String,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    alert['description']
                                                        as String,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Risk Map
              Text(
                'Disaster Risk Map',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showFullMapDialog(context),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: Stack(
                            children: [
                              // Base map with gradient background
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue[800]!,
                                        Colors.blue[600]!,
                                        Colors.blue[400]!,
                                      ],
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: MapPainter(),
                                    child:
                                        Container(), // Placeholder for map content
                                  ),
                                ),
                              ),

                              // Title overlay
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'India Disaster Risk Zones',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              // Tap instruction
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tap to view full map',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Risk indicators
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildRiskIndicator(
                                          'High Risk', Colors.red),
                                      const SizedBox(height: 4),
                                      _buildRiskIndicator(
                                        'Moderate Risk',
                                        Colors.yellow,
                                      ),
                                      const SizedBox(height: 4),
                                      _buildRiskIndicator(
                                        'Low Risk',
                                        Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay informed about disaster risks in your area. This map shows high-risk (red), moderate-risk (yellow), and low-risk (green) zones across India.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.info_outline,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Tap on the map to view the full version with zoom capability.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  List<Color> _getWeatherGradient(String description, bool isEvening) {
    final lowerDescription = description.toLowerCase();

    if (lowerDescription.contains('rain') ||
        lowerDescription.contains('drizzle')) {
      return isEvening
          ? [
              const Color(0xFF1A237E),
              const Color(0xFF0D47A1)
            ] // Dark blue for evening rain
          : [
              const Color(0xFF1976D2),
              const Color(0xFF42A5F5)
            ]; // Light blue for morning rain
    } else if (lowerDescription.contains('cloud')) {
      return isEvening
          ? [
              const Color(0xFF455A64),
              const Color(0xFF78909C)
            ] // Dark gray for evening clouds
          : [
              const Color(0xFF78909C),
              const Color(0xFFB0BEC5)
            ]; // Light gray for morning clouds
    } else if (lowerDescription.contains('clear')) {
      return isEvening
          ? [
              const Color(0xFF0D47A1),
              const Color(0xFF1A237E)
            ] // Dark blue for evening clear sky
          : [
              const Color(0xFF03A9F4),
              const Color(0xFF4FC3F7)
            ]; // Light blue for morning clear sky
    } else if (lowerDescription.contains('snow')) {
      return isEvening
          ? [
              const Color(0xFF37474F),
              const Color(0xFF546E7A)
            ] // Dark gray for evening snow
          : [
              const Color(0xFFB3E5FC),
              const Color(0xFFE1F5FE)
            ]; // Very light blue for morning snow
    } else if (lowerDescription.contains('thunder') ||
        lowerDescription.contains('storm')) {
      return isEvening
          ? [
              const Color(0xFF263238),
              const Color(0xFF37474F)
            ] // Very dark gray for evening storms
          : [
              const Color(0xFF455A64),
              const Color(0xFF607D8B)
            ]; // Mid gray for morning storms
    } else {
      // Default gradients
      return isEvening
          ? [
              const Color(0xFF303F9F),
              const Color(0xFF1976D2)
            ] // Default evening
          : [
              const Color(0xFF64B5F6),
              const Color(0xFF90CAF9)
            ]; // Default morning
    }
  }

  void _showAlertDetails(Map<String, dynamic> alert, String location) {
    showDialog(
      context: context,
      builder: (context) {
        final isAlert = alert['type'] == 'alert';
        final timestamp = alert['timestamp'] as DateTime;
        final isToday = _isToday(timestamp);

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isAlert ? Icons.warning_amber : Icons.info_outline,
                color: isAlert ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isToday
                    ? 'Today, ${_formatTime(timestamp)}'
                    : '${_formatDate(timestamp)}, ${_formatTime(timestamp)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                alert['description'] as String,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(alert['severity'] as String),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getSeverityText(alert['severity'] as String),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAlert ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isAlert ? 'ALERT' : 'WARNING',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
            TextButton(
              onPressed: () {
                // Share functionality would go here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alert shared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('SHARE'),
            ),
          ],
        );
      },
    );
  }

  List<Color> _getAlertGradient(String severity, bool isAlert) {
    if (severity == 'high') {
      return isAlert
          ? [
              const Color(0xFFD32F2F).withOpacity(0.9),
              const Color(0xFFB71C1C).withOpacity(0.9),
            ] // Red for high severity alerts
          : [
              const Color(0xFFE64A19).withOpacity(0.9),
              const Color(0xFFBF360C).withOpacity(0.9),
            ]; // Deep Orange for high severity warnings
    } else if (severity == 'moderate') {
      return isAlert
          ? [
              const Color(0xFFF57C00).withOpacity(0.9),
              const Color(0xFFEF6C00).withOpacity(0.9),
            ] // Orange for moderate severity alerts
          : [
              const Color(0xFFFFA000).withOpacity(0.9),
              const Color(0xFFFF8F00).withOpacity(0.9),
            ]; // Amber for moderate severity warnings
    } else {
      return isAlert
          ? [
              const Color(0xFF43A047).withOpacity(0.9),
              const Color(0xFF2E7D32).withOpacity(0.9),
            ] // Green for low severity alerts
          : [
              const Color(0xFF039BE5).withOpacity(0.9),
              const Color(0xFF0277BD).withOpacity(0.9),
            ]; // Light Blue for low severity warnings
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getSeverityText(String severity) {
    switch (severity) {
      case 'high':
        return 'HIGH SEVERITY';
      case 'moderate':
        return 'MODERATE SEVERITY';
      default:
        return 'LOW SEVERITY';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<Color> _getCityCardGradient(String cityName) {
    // Group cities by state and assign color families
    if (AppConstants.locationsByState['Assam']!.contains(cityName)) {
      // Assam: Blues
      return [
        const Color(0xFF1A237E).withOpacity(0.15),
        const Color(0xFF3949AB).withOpacity(0.25),
      ];
    } else if (AppConstants.locationsByState['West Bengal']!
        .contains(cityName)) {
      // West Bengal: Greens
      return [
        const Color(0xFF1B5E20).withOpacity(0.15),
        const Color(0xFF388E3C).withOpacity(0.25),
      ];
    } else if (AppConstants.locationsByState['Arunachal Pradesh']!
        .contains(cityName)) {
      // Arunachal Pradesh: Purples
      return [
        const Color(0xFF4A148C).withOpacity(0.15),
        const Color(0xFF7B1FA2).withOpacity(0.25),
      ];
    } else if (AppConstants.locationsByState['Maharashtra']!
        .contains(cityName)) {
      // Maharashtra: Oranges
      return [
        const Color(0xFFE65100).withOpacity(0.15),
        const Color(0xFFEF6C00).withOpacity(0.25),
      ];
    } else if (AppConstants.locationsByState['Delhi']!.contains(cityName)) {
      // Delhi: Reds
      return [
        const Color(0xFFB71C1C).withOpacity(0.15),
        const Color(0xFFC62828).withOpacity(0.25),
      ];
    } else {
      // Default
      return [
        Colors.grey.shade200,
        Colors.grey.shade300,
      ];
    }
  }

  Color _getShadowColor(String severity, bool isAlert) {
    if (severity == 'high') {
      return isAlert
          ? Colors.red.withOpacity(0.3)
          : Colors.deepOrange.withOpacity(0.3);
    } else if (severity == 'moderate') {
      return isAlert
          ? Colors.orange.withOpacity(0.3)
          : Colors.amber.withOpacity(0.3);
    } else {
      return isAlert
          ? Colors.green.withOpacity(0.3)
          : Colors.blue.withOpacity(0.3);
    }
  }

  List<Color> _getLocationHeaderGradient(String cityName) {
    // Group cities by state for distinctive header colors
    if (AppConstants.locationsByState['Assam']!.contains(cityName)) {
      // Assam: Blues
      return [
        const Color(0xFF1A237E),
        const Color(0xFF3949AB),
      ];
    } else if (AppConstants.locationsByState['West Bengal']!
        .contains(cityName)) {
      // West Bengal: Greens
      return [
        const Color(0xFF1B5E20),
        const Color(0xFF388E3C),
      ];
    } else if (AppConstants.locationsByState['Arunachal Pradesh']!
        .contains(cityName)) {
      // Arunachal Pradesh: Purples
      return [
        const Color(0xFF4A148C),
        const Color(0xFF7B1FA2),
      ];
    } else if (AppConstants.locationsByState['Maharashtra']!
        .contains(cityName)) {
      // Maharashtra: Oranges
      return [
        const Color(0xFFE65100),
        const Color(0xFFEF6C00),
      ];
    } else if (AppConstants.locationsByState['Delhi']!.contains(cityName)) {
      // Delhi: Reds
      return [
        const Color(0xFFB71C1C),
        const Color(0xFFC62828),
      ];
    } else {
      // Default
      return [
        Colors.blueGrey.shade700,
        Colors.blueGrey.shade500,
      ];
    }
  }

  void _showFullMapDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDarkBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'India Disaster Risk Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Interactive Map
                Expanded(
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[800]!,
                              Colors.blue[600]!,
                              Colors.blue[400]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(
                          painter: MapPainter(),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.map,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'India Disaster Risk Map',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Simulated map showing high-risk (red), moderate-risk (yellow), and low-risk (green) zones across India.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String location;
  final double temperature;
  final String description;
  final String iconUrl;
  final double humidity;
  final double windSpeed;

  const WeatherCard({
    super.key,
    required this.location,
    required this.temperature,
    required this.description,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Gradient from primary color to accent blue
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.accentBlue,
          ],
        ),
        // Add shadow for better elevation effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and Weather Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Weather Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  iconUrl,
                  width: 70,
                  height: 70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Temperature Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Main Temperature
              Text(
                '${temperature.round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Weather Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWeatherDetail(
                      Icons.water_drop, '${humidity.round()}%', 'Humidity'),
                  const SizedBox(height: 12),
                  _buildWeatherDetail(
                      Icons.air, '${windSpeed.toStringAsFixed(1)} m/s', 'Wind'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define a basic outline of India (very simplified)
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Starting point at the top (Kashmir)
    path.moveTo(size.width * 0.3, size.height * 0.1);

    // Northeastern region
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.1,
        size.width * 0.8, size.height * 0.3);

    // Eastern coast
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.5,
        size.width * 0.7, size.height * 0.8);

    // Southern tip
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.9,
        size.width * 0.5, size.height * 0.9);

    // Western coast
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.9,
        size.width * 0.2, size.height * 0.6);

    // Northwestern region
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.4,
        size.width * 0.3, size.height * 0.1);

    // Draw the outline
    canvas.drawPath(path, paint);

    // Add some high-risk zones (red circles)
    _drawRiskZone(canvas, size, 0.6, 0.3, 0.08, Colors.red.withOpacity(0.5));
    _drawRiskZone(canvas, size, 0.3, 0.7, 0.1, Colors.red.withOpacity(0.5));

    // Add some moderate-risk zones (yellow circles)
    _drawRiskZone(canvas, size, 0.4, 0.5, 0.12, Colors.yellow.withOpacity(0.5));
    _drawRiskZone(canvas, size, 0.7, 0.6, 0.09, Colors.yellow.withOpacity(0.5));

    // Add some low-risk zones (green circles)
    _drawRiskZone(canvas, size, 0.2, 0.3, 0.07, Colors.green.withOpacity(0.5));
    _drawRiskZone(canvas, size, 0.5, 0.7, 0.11, Colors.green.withOpacity(0.5));
  }

  void _drawRiskZone(Canvas canvas, Size size, double xFactor, double yFactor,
      double radiusFactor, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * xFactor, size.height * yFactor),
      size.width * radiusFactor,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
