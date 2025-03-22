import 'apikey.dart';

class AppConstants {
  // API Keys
  static const String weatherApiKey = weatherApiKeyOpenweatherMap ; //Use Openweathermap API
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Predefined Locations
  static const Map<String, Map<String, double>> predefinedLocations = {
    // Assam
    'Guwahati': {'lat': 26.1445, 'lon': 91.7362},
    'Jorhat': {'lat': 26.7509, 'lon': 94.2037},
    'Tezpur': {'lat': 26.6338, 'lon': 92.8032},
    'Nagaon': {'lat': 26.3455, 'lon': 92.6840},
    'Silchar': {'lat': 24.8333, 'lon': 92.7789},
    'Dibrugarh': {'lat': 27.4728, 'lon': 94.9120},
    // West Bengal
    'Howrah': {'lat': 22.5958, 'lon': 88.2636},
    'Siliguri': {'lat': 26.7271, 'lon': 88.3953},
    'Rampurhat': {'lat': 24.1758, 'lon': 87.7857},
    'Malda': {'lat': 25.0220, 'lon': 88.1437},
    'Kolkata': {'lat': 22.5726, 'lon': 88.3639},
    // Arunachal Pradesh
    'Itanagar': {'lat': 27.0844, 'lon': 93.6053},
    'Pasighat': {'lat': 28.0657, 'lon': 95.3285},
    'Tawang': {'lat': 27.5859, 'lon': 91.8661},
    'Ziro': {'lat': 27.5378, 'lon': 93.8260},
    // Maharashtra
    'Mumbai': {'lat': 19.0760, 'lon': 72.8777},
    'Thane': {'lat': 19.2183, 'lon': 72.9781},
    'Pune': {'lat': 18.5204, 'lon': 73.8567},
    'Nagpur': {'lat': 21.1458, 'lon': 79.0882},
    // Delhi
    'New Delhi': {'lat': 28.6139, 'lon': 77.2090},
    'North Delhi': {'lat': 28.7041, 'lon': 77.1025},
    'South Delhi': {'lat': 28.5219, 'lon': 77.2169},
    'East Delhi': {'lat': 28.6279, 'lon': 77.2952},
  };

  // Location groups by state
  static const Map<String, List<String>> locationsByState = {
    'Assam': [
      'Guwahati',
      'Jorhat',
      'Tezpur',
      'Nagaon',
      'Silchar',
      'Dibrugarh',
    ],
    'West Bengal': [
      'Howrah',
      'Siliguri',
      'Rampurhat',
      'Malda',
      'Kolkata',
    ],
    'Arunachal Pradesh': [
      'Itanagar',
      'Pasighat',
      'Tawang',
      'Ziro',
    ],
    'Maharashtra': [
      'Mumbai',
      'Thane',
      'Pune',
      'Nagpur',
    ],
    'Delhi': [
      'New Delhi',
      'North Delhi',
      'South Delhi',
      'East Delhi',
    ],
  };

  // Collection Names
  static const String usersCollection = 'users';
  static const String emergencyRequestsCollection = 'emergency_requests';
  static const String blogCollection = 'blog_posts';

  // Storage Keys
  static const String themePreference = 'theme_preference';
  static const String userRole = 'user_role';
  static const String selectedLocations = 'selected_locations';

  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String userDashboardRoute = '/user/dashboard';
  static const String adminDashboardRoute = '/admin/dashboard';
  static const String emergencyRequestRoute = '/user/emergency';
  static const String blogRoute = '/blog';
  static const String profileRoute = '/profile';
  static const String searchRoute = '/search';

  // Error Messages
  static const String wrongCredentials = 'Wrong credentials!';
  static const String unauthorizedAccess = 'Unauthorized access!';
  static const String networkError = 'Network error. Please try again.';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';

  // Success Messages
  static const String requestAccepted = 'Request Accepted';
  static const String requestSent = 'Emergency request sent successfully';
  static const String profileUpdated = 'Profile updated successfully';

  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidAadhar = 'Please enter a valid Aadhar number';

  // Risk Levels
  static const String highRisk = 'High Risk';
  static const String moderateRisk = 'Moderate Risk';
  static const String lowRisk = 'Low Risk';

  // Weather Update Intervals (in minutes)
  static const int weatherUpdateInterval = 30;

  // Predefined Alerts and Warnings by City
  static final Map<String, List<Map<String, dynamic>>> alertsByCity = {
    // Assam
    'Guwahati': [
      {
        'title': 'Severe Flooding Alert',
        'description':
            'Heavy rainfall causing severe flooding in low-lying areas. Evacuate immediately if in affected zones.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 8, 30),
      },
      {
        'title': 'Landslide Warning',
        'description':
            'Risk of landslides in hilly areas due to continuous rainfall. Avoid travel in affected regions.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 14, 15),
      },
    ],
    'Jorhat': [
      {
        'title': 'Heavy Rain Warning',
        'description':
            'Continuous rainfall expected for next 48 hours. Take necessary precautions.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 10, 0),
      },
    ],
    'Tezpur': [
      {
        'title': 'Flash Flood Alert',
        'description':
            'Flash floods reported near Brahmaputra tributaries. Avoid riverside areas.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 16, 45),
      },
      {
        'title': 'Thunderstorm Warning',
        'description':
            'Severe thunderstorms expected tonight. Secure loose objects and stay indoors.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 18, 30),
      },
    ],
    'Nagaon': [
      {
        'title': 'River Water Level Rising',
        'description':
            'Kolong River water level approaching danger mark. Residents in nearby areas advised to be vigilant.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 9, 15),
      },
    ],
    'Silchar': [
      {
        'title': 'Flood Warning',
        'description':
            'Barak River crossing danger level. Low-lying areas may experience flooding in next 24 hours.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 12, 0),
      },
    ],
    'Dibrugarh': [
      {
        'title': 'Oil Spill Alert',
        'description':
            'Oil spill reported in Dibrugarh refinery area. Avoid using water from affected streams.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 7, 30),
      },
      {
        'title': 'Air Quality Warning',
        'description':
            'Poor air quality due to industrial emissions. People with respiratory conditions advised to stay indoors.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 16, 0),
      },
    ],

    // West Bengal
    'Howrah': [
      {
        'title': 'Urban Flooding Alert',
        'description':
            'Several areas experiencing waterlogging due to heavy rainfall. Take alternate routes.',
        'type': 'alert',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 11, 45),
      },
    ],
    'Siliguri': [
      {
        'title': 'Landslide Warning',
        'description':
            'Multiple landslides reported on highways. Avoid travel to hill areas.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 7, 0),
      },
      {
        'title': 'Bridge Structural Issue',
        'description':
            'Mahananda Bridge showing signs of structural weakness. Use alternative routes until further notice.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 18, 14, 30),
      },
    ],
    'Rampurhat': [
      {
        'title': 'Heat Wave Warning',
        'description':
            'Extreme temperatures expected for next 3 days. Stay hydrated and avoid outdoor activities during peak hours.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 10, 30),
      },
    ],
    'Malda': [
      {
        'title': 'Agricultural Disease Alert',
        'description':
            'Crop disease outbreak reported in several villages. Farmers advised to contact agricultural department.',
        'type': 'alert',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 8, 45),
      },
    ],
    'Kolkata': [
      {
        'title': 'Cyclone Warning',
        'description':
            'Cyclonic storm forming in Bay of Bengal, expected to impact coastal areas within 72 hours.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 15, 0),
      },
      {
        'title': 'Metro Disruption',
        'description':
            'Metro services partially disrupted due to technical issues. Plan alternative transportation.',
        'type': 'alert',
        'severity': 'low',
        'timestamp': DateTime(2023, 3, 18, 9, 0),
      },
    ],

    // Arunachal Pradesh
    'Itanagar': [
      {
        'title': 'Landslide Warning',
        'description':
            'Multiple landslides reported on Itanagar-Naharlagun road. Avoid travel if possible.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 11, 30),
      },
    ],
    'Pasighat': [
      {
        'title': 'Flash Flood Alert',
        'description':
            'Siang River flowing above danger level. Riverside communities advised to relocate temporarily.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 14, 45),
      },
      {
        'title': 'Road Blockage',
        'description':
            'Major road to Dibrugarh blocked due to landslide. Use alternative routes.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 17, 30),
      },
    ],
    'Tawang': [
      {
        'title': 'Snowfall Alert',
        'description':
            'Heavy snowfall expected in next 24 hours. Tourist activities suspended until further notice.',
        'type': 'alert',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 9, 0),
      },
    ],
    'Ziro': [
      {
        'title': 'Forest Fire Warning',
        'description':
            'Forest fire reported near Tale Wildlife Sanctuary. Avoid nearby areas and report any sightings.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 16, 15),
      },
    ],

    // Maharashtra
    'Mumbai': [
      {
        'title': 'High Tide Alert',
        'description':
            'High tide of 4.5 meters expected today at 14:30. Avoid beaches and coastal areas.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 10, 15),
      },
      {
        'title': 'Local Train Disruption',
        'description':
            'Western line services delayed due to technical fault near Dadar. Expect delays of 20-30 minutes.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 8, 30),
      },
      {
        'title': 'Air Quality Warning',
        'description':
            'Poor air quality in eastern suburbs. People with respiratory conditions advised to take precautions.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 19, 0),
      },
    ],
    'Thane': [
      {
        'title': 'Flooding Alert',
        'description':
            'Several areas experiencing waterlogging due to heavy rainfall. Avoid Ghodbunder Road if possible.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 11, 0),
      },
      {
        'title': 'Lake Overflow Warning',
        'description':
            'Upvan Lake reaching overflow levels. Nearby residents advised to be alert.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 16, 45),
      },
    ],
    'Pune': [
      {
        'title': 'Dam Release Warning',
        'description':
            'Khadakwasla Dam releasing water. Residents along riverside areas advised to stay alert.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 9, 45),
      },
      {
        'title': 'Traffic Congestion Alert',
        'description':
            'Major traffic jam on Pune-Mumbai Expressway due to accident. Expect delays of over an hour.',
        'type': 'alert',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 17, 30),
      },
      {
        'title': 'Dengue Outbreak Warning',
        'description':
            'Increasing cases of dengue reported in Kothrud area. Take precautions against mosquito breeding.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 14, 0),
      },
    ],
    'Nagpur': [
      {
        'title': 'Heat Wave Warning',
        'description':
            'Temperatures expected to exceed 45°C for next 3 days. Avoid outdoor activities between 11 AM and 4 PM.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 8, 0),
      },
      {
        'title': 'Water Shortage Alert',
        'description':
            'Several areas to experience water supply disruption due to maintenance work. Store water for next 24 hours.',
        'type': 'alert',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 18, 18, 15),
      },
    ],

    // Delhi
    'New Delhi': [
      {
        'title': 'Air Pollution Alert',
        'description':
            'AQI exceeding 300 in many areas. People advised to wear masks and limit outdoor exposure.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 10, 45),
      },
      {
        'title': 'Traffic Disruption',
        'description':
            'Major protest at India Gate area. Avoid central Delhi until further notice.',
        'type': 'warning',
        'severity': 'moderate',
        'timestamp': DateTime(2023, 3, 19, 15, 30),
      },
      {
        'title': 'Metro Service Interruption',
        'description':
            'Yellow Line services affected due to technical issue. Delays of 15-20 minutes expected.',
        'type': 'alert',
        'severity': 'low',
        'timestamp': DateTime(2023, 3, 18, 9, 30),
      },
    ],
    'North Delhi': [
      {
        'title': 'Water Contamination Warning',
        'description':
            'Contaminated water supply reported in several areas. Boil water before consumption.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 11, 15),
      },
    ],
    'South Delhi': [
      {
        'title': 'Building Collapse Alert',
        'description':
            'Old building collapsed in Lajpat Nagar area. Avoid the area as rescue operations are ongoing.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 7, 45),
      },
      {
        'title': 'Road Closure',
        'description':
            'Aurobindo Marg closed for repairs from 10 PM to 5 AM tonight. Use alternative routes.',
        'type': 'warning',
        'severity': 'low',
        'timestamp': DateTime(2023, 3, 18, 19, 45),
      },
    ],
    'East Delhi': [
      {
        'title': 'Yamuna Flood Warning',
        'description':
            'Yamuna water level rising. Low-lying areas near riverbanks on alert.',
        'type': 'warning',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 19, 16, 0),
      },
      {
        'title': 'Gas Leak Alert',
        'description':
            'Gas leak reported in Patparganj industrial area. Nearby residents advised to close windows and stay indoors.',
        'type': 'alert',
        'severity': 'high',
        'timestamp': DateTime(2023, 3, 18, 21, 30),
      },
    ],
  };

  // Rescue Centers Data
  static final Map<String, List<Map<String, dynamic>>> rescueCentersByCity = {
    // Assam
    'Guwahati': [
      {
        'name': 'Guwahati Relief Center',
        'address': '12 MG Road, Fancy Bazar, Guwahati',
        'phone': '+91 9876543210',
        'capacity': 200,
        'occupancy': 160,
        'bedAvailability': 40,
        'mealsAvailable': 85, // percentage
        'fundingStatus': 'Funding Required',
        'description':
            'Primary disaster relief center serving Guwahati and surrounding areas. Provides shelter, food, medical assistance and rehabilitation support.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter', 'Counseling'],
        'imageUrl': 'https://example.com/guwahati_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Less Beds', 'Funding Required'],
      },
      {
        'name': 'North Guwahati Shelter Home',
        'address': '45 River View, North Guwahati',
        'phone': '+91 9876123450',
        'capacity': 150,
        'occupancy': 135,
        'bedAvailability': 15,
        'mealsAvailable': 92, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Secondary relief center focused on long-term rehabilitation and family reunification after disasters.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Family Reunification'
        ],
        'imageUrl': 'https://example.com/north_guwahati_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Less Beds', 'Well Equipped'],
      },
    ],
    'Jorhat': [
      {
        'name': 'Jorhat Disaster Management Center',
        'address': '78 AT Road, Jorhat',
        'phone': '+91 9876543211',
        'capacity': 120,
        'occupancy': 50,
        'bedAvailability': 70,
        'mealsAvailable': 100, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Full-service disaster response center equipped with modern facilities and trained personnel.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Child Care'
        ],
        'imageUrl': 'https://example.com/jorhat_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Child Friendly'],
      },
    ],
    'Tezpur': [
      {
        'name': 'Tezpur Relief Hub',
        'address': '23 Mission Chariali, Tezpur',
        'phone': '+91 9876543212',
        'capacity': 180,
        'occupancy': 175,
        'bedAvailability': 5,
        'mealsAvailable': 60, // percentage
        'fundingStatus': 'Urgent Funding Required',
        'description':
            'Primary relief center for the Sonitpur district, currently operating at near capacity due to recent flooding.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter'],
        'imageUrl': 'https://example.com/tezpur_center.jpg',
        'status': 'Active',
        'isFull': true,
        'tags': ['Nearly Full', 'Urgent Funding Required', 'Food Shortage'],
      },
    ],
    'Silchar': [
      {
        'name': 'Silchar Emergency Shelter',
        'address': '56 National Highway, Silchar',
        'phone': '+91 9876543213',
        'capacity': 250,
        'occupancy': 100,
        'bedAvailability': 150,
        'mealsAvailable': 90, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Large capacity relief center serving the Barak Valley region with comprehensive support services.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Educational Services'
        ],
        'imageUrl': 'https://example.com/silchar_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Education Support'],
      },
    ],
    'Nagaon': [
      {
        'name': 'Nagaon District Relief Center',
        'address': '45 Central Road, Nagaon',
        'phone': '+91 9876543221',
        'capacity': 180,
        'occupancy': 100,
        'bedAvailability': 80,
        'mealsAvailable': 95, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Primary relief center for Nagaon district providing comprehensive emergency services and support.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Family Reunification'
        ],
        'imageUrl': 'https://example.com/nagaon_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Family Support'],
      },
    ],
    'Dibrugarh': [
      {
        'name': 'Dibrugarh Emergency Center',
        'address': '78 Main Road, Dibrugarh',
        'phone': '+91 9876543222',
        'capacity': 150,
        'occupancy': 120,
        'bedAvailability': 30,
        'mealsAvailable': 85, // percentage
        'fundingStatus': 'Funding Required',
        'description':
            'Essential emergency relief center serving the Dibrugarh region with a focus on flood response.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter', 'Counseling'],
        'imageUrl': 'https://example.com/dibrugarh_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Funding Required'],
      },
    ],
    // West Bengal
    'Howrah': [
      {
        'name': 'Howrah Central Relief Center',
        'address': '34 GT Road, Howrah',
        'phone': '+91 9876543214',
        'capacity': 300,
        'occupancy': 290,
        'bedAvailability': 10,
        'mealsAvailable': 75, // percentage
        'fundingStatus': 'Funding Required',
        'description':
            'Main relief center for Howrah district, currently operating near capacity due to monsoon flooding.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter', 'Counseling'],
        'imageUrl': 'https://example.com/howrah_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Nearly Full', 'Funding Required'],
      },
    ],
    'Siliguri': [
      {
        'name': 'Siliguri Disaster Response Center',
        'address': '89 Hill View Road, Siliguri',
        'phone': '+91 9876543215',
        'capacity': 220,
        'occupancy': 120,
        'bedAvailability': 100,
        'mealsAvailable': 95, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Strategic relief center serving North Bengal and surrounding hill regions, specializing in landslide and flood response.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Search and Rescue'
        ],
        'imageUrl': 'https://example.com/siliguri_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Rescue Operations'],
      },
    ],
    'Kolkata': [
      {
        'name': 'Kolkata Urban Relief Center',
        'address': '112 Park Street, Kolkata',
        'phone': '+91 9876543216',
        'capacity': 400,
        'occupancy': 200,
        'bedAvailability': 200,
        'mealsAvailable': 100, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Large urban relief center with comprehensive facilities for all types of disasters and emergencies.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Rehabilitation',
          'Legal Aid'
        ],
        'imageUrl': 'https://example.com/kolkata_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Legal Support'],
      },
    ],
    'Rampurhat': [
      {
        'name': 'Rampurhat Community Shelter',
        'address': '34 Station Road, Rampurhat',
        'phone': '+91 9876543223',
        'capacity': 120,
        'occupancy': 80,
        'bedAvailability': 40,
        'mealsAvailable': 90, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Community-focused relief center providing aid and support to rural populations in the region.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Educational Services'
        ],
        'imageUrl': 'https://example.com/rampurhat_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Education Support'],
      },
    ],
    'Malda': [
      {
        'name': 'Malda District Relief Center',
        'address': '56 River Bank Road, Malda',
        'phone': '+91 9876543224',
        'capacity': 200,
        'occupancy': 190,
        'bedAvailability': 10,
        'mealsAvailable': 70, // percentage
        'fundingStatus': 'Urgent Funding Required',
        'description':
            'Main relief center for Malda district, currently experiencing high demand due to seasonal flooding.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter'],
        'imageUrl': 'https://example.com/malda_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Nearly Full', 'Urgent Funding Required'],
      },
    ],
    // Arunachal Pradesh
    'Itanagar': [
      {
        'name': 'Itanagar Central Relief Center',
        'address': '23 Himalayan View, Itanagar',
        'phone': '+91 9876543225',
        'capacity': 180,
        'occupancy': 90,
        'bedAvailability': 90,
        'mealsAvailable': 100, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Primary relief center for the capital region with specialized mountain rescue capabilities.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Mountain Rescue'
        ],
        'imageUrl': 'https://example.com/itanagar_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Mountain Rescue'],
      },
    ],
    'Pasighat': [
      {
        'name': 'Pasighat Community Center',
        'address': '12 Siang River Road, Pasighat',
        'phone': '+91 9876543226',
        'capacity': 150,
        'occupancy': 75,
        'bedAvailability': 75,
        'mealsAvailable': 85, // percentage
        'fundingStatus': 'Funding Required',
        'description':
            'Relief center serving the eastern region of Arunachal, specializing in flood response and rehabilitation.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Rehabilitation'
        ],
        'imageUrl': 'https://example.com/pasighat_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Funding Required', 'Rehabilitation Services'],
      },
    ],
    'Tawang': [
      {
        'name': 'Tawang Mountain Rescue Center',
        'address': '8 Monastery Road, Tawang',
        'phone': '+91 9876543227',
        'capacity': 120,
        'occupancy': 30,
        'bedAvailability': 90,
        'mealsAvailable': 100, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Specialized center for mountain emergencies and winter disasters in the high-altitude Tawang region.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Mountain Rescue',
          'Winter Equipment'
        ],
        'imageUrl': 'https://example.com/tawang_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Mountain Rescue'],
      },
    ],
    'Ziro': [
      {
        'name': 'Ziro Valley Relief Center',
        'address': '45 Pine View, Ziro',
        'phone': '+91 9876543228',
        'capacity': 100,
        'occupancy': 80,
        'bedAvailability': 20,
        'mealsAvailable': 75, // percentage
        'fundingStatus': 'Funding Required',
        'description':
            'Community relief center serving the Ziro Valley region with a focus on landslide and flood response.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter', 'Counseling'],
        'imageUrl': 'https://example.com/ziro_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Funding Required'],
      },
    ],
    // Maharashtra
    'Mumbai': [
      {
        'name': 'Mumbai Coastal Relief Center',
        'address': '78 Marine Drive, Mumbai',
        'phone': '+91 9876543217',
        'capacity': 500,
        'occupancy': 350,
        'bedAvailability': 150,
        'mealsAvailable': 90, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Major metropolitan relief center specializing in flood and coastal disaster response.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Family Reunification'
        ],
        'imageUrl': 'https://example.com/mumbai_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Family Support'],
      },
      {
        'name': 'Dharavi Community Shelter',
        'address': '23 Main Street, Dharavi, Mumbai',
        'phone': '+91 9876543218',
        'capacity': 300,
        'occupancy': 290,
        'bedAvailability': 10,
        'mealsAvailable': 65, // percentage
        'fundingStatus': 'Urgent Funding Required',
        'description':
            'Community-based relief center serving one of Mumbai\'s largest urban communities.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter', 'Child Care'],
        'imageUrl': 'https://example.com/dharavi_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Nearly Full', 'Urgent Funding Required', 'Food Shortage'],
      },
    ],
    'Thane': [
      {
        'name': 'Thane Emergency Relief Center',
        'address': '67 Lake City Road, Thane',
        'phone': '+91 9876543229',
        'capacity': 300,
        'occupancy': 150,
        'bedAvailability': 150,
        'mealsAvailable': 90, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Major relief center serving the Thane district with comprehensive disaster response capabilities.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Family Reunification'
        ],
        'imageUrl': 'https://example.com/thane_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Family Support'],
      },
    ],
    'Pune': [
      {
        'name': 'Pune Urban Relief Center',
        'address': '89 University Road, Pune',
        'phone': '+91 9876543230',
        'capacity': 350,
        'occupancy': 200,
        'bedAvailability': 150,
        'mealsAvailable': 95, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Comprehensive urban relief center with specialized facilities for all types of emergencies.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Rehabilitation',
          'Legal Aid'
        ],
        'imageUrl': 'https://example.com/pune_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Legal Support'],
      },
    ],
    'Nagpur': [
      {
        'name': 'Nagpur Central Relief Hub',
        'address': '34 Orange City Road, Nagpur',
        'phone': '+91 9876543231',
        'capacity': 250,
        'occupancy': 100,
        'bedAvailability': 150,
        'mealsAvailable': 100, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Regional disaster response center serving eastern Maharashtra with comprehensive facilities.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Rehabilitation'
        ],
        'imageUrl': 'https://example.com/nagpur_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Rehabilitation Services'],
      },
    ],
    // Delhi
    'New Delhi': [
      {
        'name': 'New Delhi Central Relief Hub',
        'address': '45 Connaught Place, New Delhi',
        'phone': '+91 9876543219',
        'capacity': 450,
        'occupancy': 200,
        'bedAvailability': 250,
        'mealsAvailable': 100, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Major metropolitan relief center with comprehensive facilities for all types of urban emergencies.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Rehabilitation',
          'Legal Aid'
        ],
        'imageUrl': 'https://example.com/delhi_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Legal Support'],
      },
    ],
    'North Delhi': [
      {
        'name': 'North Delhi Emergency Shelter',
        'address': '67 Civil Lines, North Delhi',
        'phone': '+91 9876543220',
        'capacity': 250,
        'occupancy': 240,
        'bedAvailability': 10,
        'mealsAvailable': 70, // percentage
        'fundingStatus': 'Funding Required',
        'description':
            'Relief center serving North Delhi region, currently experiencing high occupancy due to recent emergencies.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter'],
        'imageUrl': 'https://example.com/north_delhi_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Nearly Full', 'Funding Required'],
      },
    ],
    'South Delhi': [
      {
        'name': 'South Delhi Relief Center',
        'address': '45 Saket District, South Delhi',
        'phone': '+91 9876543232',
        'capacity': 300,
        'occupancy': 180,
        'bedAvailability': 120,
        'mealsAvailable': 90, // percentage
        'fundingStatus': 'Well Funded',
        'description':
            'Modern relief center serving South Delhi with comprehensive emergency support services.',
        'facilities': [
          'Medical Aid',
          'Food Service',
          'Shelter',
          'Counseling',
          'Psychological Support'
        ],
        'imageUrl': 'https://example.com/south_delhi_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Well Equipped', 'Mental Health Support'],
      },
    ],
    'East Delhi': [
      {
        'name': 'East Delhi Community Shelter',
        'address': '78 Yamuna Bank Road, East Delhi',
        'phone': '+91 9876543233',
        'capacity': 220,
        'occupancy': 200,
        'bedAvailability': 20,
        'mealsAvailable': 80, // percentage
        'fundingStatus': 'Funding Required',
        'description':
            'Community-based relief center serving East Delhi residents with essential emergency services.',
        'facilities': ['Medical Aid', 'Food Service', 'Shelter', 'Child Care'],
        'imageUrl': 'https://example.com/east_delhi_center.jpg',
        'status': 'Active',
        'isFull': false,
        'tags': ['Nearly Full', 'Funding Required', 'Child Care'],
      },
    ],
  };
}
