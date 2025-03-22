import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Lists for blog posts by category
  List<Map<String, dynamic>> _preparednessPosts = [];
  List<Map<String, dynamic>> _governmentUpdates = [];
  List<Map<String, dynamic>> _communityAlerts = [];

  final List<Map<String, dynamic>> _preparednessPostsHardcoded = [
    {
      'title': 'How to Prepare for an Earthquake',
      'date': '12 March 2023',
      'author': 'Dr. Sameer Singh',
      'category': 'disaster_preparedness',
      'imageUrl':
          'https://images.unsplash.com/photo-1639152437756-e92e9ee1807a',
      'summary':
          'Essential steps to take before, during, and after an earthquake to stay safe.',
      'tags': ['Earthquake', 'Safety', 'Preparedness'],
      'content': '''
## Before an Earthquake
1. **Secure heavy furniture** to walls and move heavy objects to lower shelves
2. **Create an emergency plan** with your family, including meeting points
3. **Prepare an emergency kit** with water, food, medications, and important documents
4. **Know how to turn off utilities** like gas, water, and electricity
5. **Identify safe spots** in each room – under sturdy tables or against interior walls

## During an Earthquake
1. **DROP, COVER, AND HOLD ON** – Drop to the ground, take cover under a sturdy table, and hold on
2. **Stay indoors** until the shaking stops
3. **Stay away from windows, outside doors, and walls**
4. **If outdoors**, move to an open area away from buildings, trees, and power lines
5. **If in a vehicle**, pull over and stay inside until the shaking stops

## After an Earthquake
1. **Check yourself and others for injuries**
2. **Be prepared for aftershocks**
3. **Listen to local news** for emergency information
4. **Check for gas leaks, electrical damage, or water line damage**
5. **Stay out of damaged buildings**

Remember, preparation is key to surviving an earthquake safely!
      ''',
    },
    {
      'title': 'Flood Safety Precautions',
      'date': '5 April 2023',
      'author': 'Anjali Mehta',
      'category': 'disaster_preparedness',
      'imageUrl':
          'https://images.unsplash.com/photo-1523201726401-44f67fa517fc',
      'summary':
          'Critical flood safety measures everyone should know to protect their family and property.',
      'tags': ['Flood', 'Safety', 'Monsoon'],
      'content': '''
## Before a Flood
1. **Understand your risk** - Know if your area is prone to flooding
2. **Prepare an emergency kit** with food, water, medications for at least 3 days
3. **Create an evacuation plan** for your family and practice it
4. **Elevate electrical systems** and waterproof your basement
5. **Get flood insurance** if you live in a high-risk area

## During a Flood
1. **Stay informed** through radio, TV, or online alerts
2. **Evacuate immediately** if ordered by authorities
3. **Never walk or drive through floodwaters** – just 6 inches of water can knock you down
4. **Move to higher ground** if flash flooding is possible
5. **Turn off utilities** if instructed to do so

## After a Flood
1. **Return home only when authorities say it's safe**
2. **Watch for debris and eroded roads**
3. **Clean and disinfect everything** that got wet
4. **Document damage** with photos for insurance
5. **Avoid floodwaters** which may be contaminated

Stay alert and prepared during monsoon season!
      ''',
    },
    {
      'title': 'Fire Safety at Home',
      'date': '20 May 2023',
      'author': 'Rakesh Kumar',
      'category': 'disaster_preparedness',
      'imageUrl':
          'https://images.unsplash.com/photo-1584046927837-35dae14ae33c',
      'summary':
          'Simple steps to prevent fires and what to do if one occurs in your home.',
      'tags': ['Fire', 'Safety', 'Home'],
      'content': '''
## Preventing Home Fires
1. **Test smoke alarms monthly** and replace batteries at least once a year
2. **Keep flammable items** at least 3 feet from heat sources
3. **Never leave cooking unattended**
4. **Don't overload electrical outlets**
5. **Keep portable heaters away** from curtains, bedding, and flammable materials

## In Case of Fire
1. **Get out immediately** - don't waste time gathering possessions
2. **Close doors behind you** to slow the spread of fire
3. **Call emergency services** from outside the building
4. **Stay low** where there's less smoke if you must move through smoke
5. **If your clothes catch fire**: Stop, Drop, and Roll

## Fire Escape Plan
1. **Create a fire escape plan** with two ways out of each room
2. **Practice your escape plan** with your family regularly
3. **Designate a meeting place** outside your home
4. **Make sure windows can be opened** and screens removed quickly
5. **Consider escape ladders** for upper floors

Prevention and preparation can save your life during a fire emergency!
      ''',
    },
  ];

  final List<Map<String, dynamic>> _governmentUpdatesHardcoded = [
    {
      'title': 'Government Launches New Disaster Alert System',
      'date': '3 June 2023',
      'author': 'Ministry of Disaster Management',
      'category': 'government_updates',
      'imageUrl':
          'https://images.unsplash.com/photo-1569235186275-626cb53b83ce',
      'summary':
          'A nationwide alert system to provide instant disaster warnings through mobile phones.',
      'tags': ['Government', 'Alert System', 'Technology'],
      'content': '''
The Ministry of Disaster Management today launched a new nationwide alert system that will send instant disaster warnings directly to citizens' mobile phones. The system, called "Alert India," will use cell broadcast technology to send alerts about impending disasters such as floods, earthquakes, and cyclones.

"This technology allows us to reach millions of people simultaneously within seconds," said the Disaster Management Secretary. "Even in areas with congested networks, these alerts will get through."

The system will be rolled out in phases, starting with coastal areas prone to cyclones, followed by flood-prone regions, and then nationwide. Citizens don't need to download any app or register for the service - any compatible mobile phone in the affected area will receive the alerts automatically.

The alerts will provide:
- The type of disaster
- Expected time of impact
- Severity level
- Safety instructions
- Evacuation directions if necessary

Officials urged citizens to take these alerts seriously and follow the provided instructions when received.
      ''',
    },
    {
      'title': 'Relief Fund Allocation Increased for Affected Areas',
      'date': '15 July 2023',
      'author': 'Finance Department',
      'category': 'government_updates',
      'imageUrl':
          'https://images.unsplash.com/photo-1579621970590-9d624316904b',
      'summary':
          'Government has increased disaster relief funding by 40% to support affected communities.',
      'tags': ['Relief Fund', 'Government', 'Aid'],
      'content': '''
The Central Government has approved a 40% increase in the allocation for the National Disaster Relief Fund (NDRF) for the current financial year. This decision comes after recent disasters affected multiple states across the country.

The Finance Minister announced that the enhanced fund will help provide immediate relief to disaster-affected communities and support rebuilding efforts. "Our priority is ensuring that those affected receive timely assistance and can rebuild their lives," the minister stated.

Key aspects of the increased funding:

- ₹12,000 crore additional allocation to the NDRF
- Immediate release of ₹3,500 crore to the most severely affected states
- Simplified procedures for states to access funds during emergencies
- Dedicated funding for temporary housing solutions
- Increased compensation for crop damage and livestock loss

State governments welcomed the move, with many noting that the increased funding will help improve disaster response capabilities and provide better support to affected citizens.

The government has also established a monitoring committee to ensure timely disbursement of funds and proper utilization of resources.
      ''',
    },
    {
      'title': 'New Training Program for Community Disaster Response Teams',
      'date': '28 August 2023',
      'author': 'National Disaster Response Force',
      'category': 'government_updates',
      'imageUrl':
          'https://images.unsplash.com/photo-1612930566784-78a46e9aaafe',
      'summary':
          'NDRF launches nationwide training program to create local disaster response teams in vulnerable communities.',
      'tags': ['Training', 'Community', 'NDRF'],
      'content': '''
The National Disaster Response Force (NDRF) has launched a comprehensive training program to create Community Disaster Response Teams (CDRTs) across the country. The initiative aims to train local volunteers in basic disaster response skills, enabling communities to take immediate action before professional help arrives.

"The first 72 hours after a disaster are critical. By training community members, we can ensure faster response and save more lives," said the NDRF Director General during the program launch.

The training program will cover:

- Basic search and rescue techniques
- First aid and medical triage
- Fire safety and suppression
- Evacuation management
- Communication during disasters
- Psychological first aid

The program will initially target 500 vulnerable villages and urban areas across 15 states, with plans to expand nationwide within three years. Each CDRT will consist of 20-25 volunteers who will receive regular training and equipment.

Local authorities praised the initiative, noting that it will significantly improve disaster resilience, especially in remote areas where professional help may take longer to arrive.

Interested volunteers can register through their local administration offices or online at the NDRF website.
      ''',
    },
  ];

  final List<Map<String, dynamic>> _communityAlertsHardcoded = [
    {
      'title': 'Heavy Rainfall Expected in Western Regions',
      'date': '10 September 2023',
      'author': 'Meteorological Department',
      'category': 'alerts',
      'imageUrl': 'https://images.unsplash.com/photo-1562155955-ee72c0f8daf2',
      'summary':
          'Weather alert: Heavy rainfall predicted for the next 72 hours. Residents advised to take precautions.',
      'tags': ['Weather', 'Rainfall', 'Alert'],
      'content': '''
## URGENT WEATHER ALERT

The Meteorological Department has issued a heavy rainfall warning for the western regions of the country over the next 72 hours. Rainfall of 15-20 cm per day is expected, which may lead to localized flooding in low-lying areas.

### Areas Likely to be Affected:
- Mumbai and surrounding districts
- Coastal Gujarat
- Western Maharashtra
- Southern Rajasthan

### Advisories:
- Avoid unnecessary travel during heavy rainfall
- Stay away from flood-prone areas and riverbanks
- Keep emergency supplies ready
- Monitor local news for updates
- Follow instructions from local authorities
- Ensure proper drainage around your home

Fishermen are advised not to venture into the sea during this period due to rough sea conditions and strong winds.

Emergency contact numbers:
- Disaster Control Room: 1078
- Flood Control Room: 1070
- Ambulance: 108
      ''',
    },
    {
      'title': 'Cyclone Vayu Update: Orange Alert Issued',
      'date': '5 October 2023',
      'author': 'Cyclone Warning Center',
      'category': 'alerts',
      'imageUrl':
          'https://images.unsplash.com/photo-1527482103059-7a7d59b49cd8',
      'summary':
          'Cyclone Vayu intensifies to a Category 2 storm. Orange alert issued for coastal regions.',
      'tags': ['Cyclone', 'Alert', 'Evacuation'],
      'content': '''
## CYCLONE VAYU UPDATE - ORANGE ALERT

The Cyclone Warning Center has issued an Orange Alert as Cyclone Vayu has intensified into a Category 2 storm in the Arabian Sea. The cyclone is moving northwestward at 14 km/h and is expected to make landfall within 48 hours.

### Current Status:
- Wind speed: 155-165 km/h, gusting to 180 km/h
- Location: 350 km southwest of Mumbai
- Expected landfall: Gujarat coast between Dwarka and Porbandar

### Areas Under Orange Alert:
- Entire Gujarat coastline
- Northern Maharashtra coast
- Southern Rajasthan

### Advisories:
- Evacuation has begun in coastal villages
- Avoid coastal areas completely
- Secure loose objects that could become projectiles
- Stock up on essentials and medication
- Keep important documents in waterproof containers
- Charge mobile phones and power banks
- Follow evacuation orders without delay

All fishing operations have been suspended. Port authorities have hoisted Distant Warning Signal No. 2 at all ports along the western coast.

The situation is being monitored continuously, and updates will be provided every 3 hours.

Emergency Helpline: 1070
      ''',
    },
    {
      'title': 'Heat Wave Warning: Take Precautions',
      'date': '22 June 2023',
      'author': 'Health Department',
      'category': 'alerts',
      'imageUrl':
          'https://images.unsplash.com/photo-1524594081293-190a2fe0baae',
      'summary':
          'Extreme heat wave conditions expected to continue for 5 days. Health advisory issued.',
      'tags': ['Heat Wave', 'Health', 'Summer'],
      'content': '''
## HEAT WAVE WARNING

The Meteorological Department and Health Department have jointly issued a severe heat wave warning for the following regions:
- Delhi NCR
- Haryana
- Punjab
- Rajasthan
- Uttar Pradesh
- Madhya Pradesh

Temperatures are expected to reach 44-47°C over the next 5 days.

### Health Advisories:

1. **Stay Hydrated**
   - Drink plenty of water, even if not thirsty
   - Avoid alcohol, coffee, tea, and carbonated drinks

2. **Stay Cool**
   - Remain indoors during peak hours (11 am - 4 pm)
   - Use fans, air-conditioning, or visit cooling centers
   - Take cool showers or baths
   - Wear lightweight, light-colored, loose-fitting clothing

3. **Protect Others**
   - Check on elderly neighbors and those without air conditioning
   - Never leave children or pets in parked vehicles
   - Provide fresh water for pets and outdoor animals

4. **Outdoor Work**
   - Take frequent breaks in shaded or cool areas
   - Work during cooler hours if possible
   - Work with a partner and monitor each other

5. **Recognize Heat Illness**
   Seek immediate medical help if you experience:
   - High body temperature
   - Hot, red, dry skin
   - Rapid, strong pulse
   - Dizziness, nausea, or confusion

Special arrangements for drinking water have been made at public places. Schools will remain closed until further notice.

Heat Stress Helpline: 108
      ''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBlogPosts();
  }

  Future<void> _loadBlogPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear existing posts
      _preparednessPosts = [];
      _governmentUpdates = [];
      _communityAlerts = [];

      // Fetch blog posts from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection(AppConstants.blogCollection)
          .orderBy('createdAt', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // No posts in Firestore
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Sort posts by category
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        // Ensure we have the document ID
        data['id'] = doc.id;

        // Add to appropriate list based on category
        switch (data['category']) {
          case 'disaster_preparedness':
            _preparednessPosts.add(data);
            break;
          case 'government_updates':
            _governmentUpdates.add(data);
            break;
          case 'alerts':
            _communityAlerts.add(data);
            break;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading blog posts: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFullPost(BuildContext context, Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.blueGrey.shade200,
                  child: Icon(
                    _getCategoryIcon(post['category']),
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'By ${post['author']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            post['date'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: (post['tags'] as List<dynamic>)
                            .map((tag) => Chip(
                                  label: Text(tag.toString()),
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  labelStyle: TextStyle(fontSize: 12),
                                  padding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                      const Divider(height: 24),
                      Text(
                        post['content'],
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Blogs & Updates',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for safety tips, alerts...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),

          // Tabs
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(
                  icon: Icon(Icons.shield),
                  text: "Safety Tips",
                ),
                Tab(
                  icon: Icon(Icons.public),
                  text: "Updates",
                ),
                Tab(
                  icon: Icon(Icons.warning),
                  text: "Alerts",
                ),
              ],
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Safety Tips tab
                _buildPreparednessTab(),

                // Government Updates tab
                _buildUpdatesTab(),

                // Alerts tab
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreparednessTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_preparednessPosts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBlogPosts,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState(
                'No safety tips available yet.\nPull down to refresh.',
                Icons.shield_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlogPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _preparednessPosts.length,
        itemBuilder: (context, index) {
          final post = _preparednessPosts[index];
          return _buildPostCard(context, post);
        },
      ),
    );
  }

  Widget _buildUpdatesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_governmentUpdates.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBlogPosts,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState(
                'No government updates available yet.\nPull down to refresh.',
                Icons.public_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlogPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _governmentUpdates.length,
        itemBuilder: (context, index) {
          final post = _governmentUpdates[index];
          return _buildPostCard(context, post);
        },
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_communityAlerts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBlogPosts,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState(
                'No alerts available yet.\nPull down to refresh.',
                Icons.warning_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlogPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _communityAlerts.length,
        itemBuilder: (context, index) {
          final post = _communityAlerts[index];
          return _buildAlertCard(context, post);
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showFullPost(context, post),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post image/header
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryColor(post['category']),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(post['category']),
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),

            // Post content preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(post['category'])
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getCategoryName(post['category']),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(post['category']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post['date'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post['title'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['summary'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Tags and action
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (post['tags'] as List<dynamic>)
                              .take(2)
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tag.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showFullPost(context, post),
                        icon: const Icon(Icons.read_more),
                        label: const Text('Read More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> alert) {
    final isUrgent = alert['category'] == 'alerts';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUrgent
            ? BorderSide(color: Colors.red.withOpacity(0.5), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showFullPost(context, alert),
        child: Column(
          children: [
            // Alert header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade100 : Colors.orange.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUrgent ? Icons.warning : Icons.info_outline,
                    color: isUrgent ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isUrgent ? 'URGENT ALERT' : 'ADVISORY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? Colors.red : Colors.orange,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    alert['date'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Alert content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert['summary'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showFullPost(context, alert),
                        icon: const Icon(Icons.read_more),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isUrgent ? Colors.red : Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Share functionality
                        },
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'disaster_preparedness':
        return Icons.shield;
      case 'government_updates':
        return Icons.public;
      case 'alerts':
        return Icons.warning;
      default:
        return Icons.article;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'disaster_preparedness':
        return Colors.blue;
      case 'government_updates':
        return Colors.green;
      case 'alerts':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'disaster_preparedness':
        return 'Safety Tips';
      case 'government_updates':
        return 'Govt Updates';
      case 'alerts':
        return 'Alert';
      default:
        return 'Article';
    }
  }
}
