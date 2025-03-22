import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class AdminCityMonitorScreen extends StatefulWidget {
  const AdminCityMonitorScreen({Key? key}) : super(key: key);

  @override
  State<AdminCityMonitorScreen> createState() => _AdminCityMonitorScreenState();
}

class _AdminCityMonitorScreenState extends State<AdminCityMonitorScreen> {
  String _filterState = 'All States';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getFilteredCities() {
    final cities = AppConstants.rescueCentersByCity.keys.toList();

    if (_searchQuery.isNotEmpty) {
      return cities
          .where(
              (city) => city.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_filterState == 'All States') {
      return cities;
    }

    // Filter by state
    return AppConstants.locationsByState[_filterState] ?? [];
  }

  List<String> _getAvailableStates() {
    final states = ['All States'];
    states.addAll(AppConstants.locationsByState.keys.toList());
    return states;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCities = _getFilteredCities();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search cities...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // State filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterState,
                      isExpanded: true,
                      icon: const Icon(Icons.filter_list),
                      items: _getAvailableStates().map((state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _filterState = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildStatsSummary(),
          ),

          // Cities list
          Expanded(
            child: filteredCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_city_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No cities found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      return _buildCityCard(city);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    // Calculate total centers, beds and occupancy
    int totalCenters = 0;
    int totalCapacity = 0;
    int totalOccupancy = 0;

    AppConstants.rescueCentersByCity.forEach((city, centers) {
      totalCenters += centers.length;

      for (final center in centers) {
        totalCapacity += center['capacity'] as int;
        totalOccupancy += center['occupancy'] as int;
      }
    });

    final availableBeds = totalCapacity - totalOccupancy;
    final occupancyRate = totalCapacity > 0
        ? (totalOccupancy / totalCapacity * 100).toStringAsFixed(1)
        : '0';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade800,
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'National Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                    'Total\nCenters', totalCenters.toString(), Icons.apartment),
                const SizedBox(width: 16),
                _buildStatItem(
                    'Total\nCapacity', totalCapacity.toString(), Icons.people),
                const SizedBox(width: 16),
                _buildStatItem(
                    'Available\nBeds', availableBeds.toString(), Icons.hotel),
                const SizedBox(width: 16),
                _buildStatItem(
                    'Occupancy\nRate', '$occupancyRate%', Icons.pie_chart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue.shade100,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCityCard(String city) {
    final centers = AppConstants.rescueCentersByCity[city] ?? [];
    if (centers.isEmpty) return const SizedBox.shrink();

    // Calculate city stats
    int totalCapacity = 0;
    int totalOccupancy = 0;
    bool hasCriticalCenter = false;

    for (final center in centers) {
      totalCapacity += center['capacity'] as int;
      totalOccupancy += center['occupancy'] as int;

      if (center['bedAvailability'] < 20 ||
          center['isFull'] == true ||
          center['fundingStatus'] == 'Urgent Funding Required') {
        hasCriticalCenter = true;
      }
    }

    final availableBeds = totalCapacity - totalOccupancy;
    final occupancyRate =
        (totalOccupancy / totalCapacity * 100).toStringAsFixed(0);

    // Determine status color
    Color statusColor = Colors.green;
    if (availableBeds < 30) {
      statusColor = Colors.orange;
    }
    if (availableBeds < 10 || hasCriticalCenter) {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.location_city, color: statusColor),
        ),
        title: Text(
          city,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Text('${centers.length} centers'),
                Text('$availableBeds beds available'),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$occupancyRate%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
        children: [
          const Divider(),
          ...centers.map((center) => _buildCenterListItem(center)).toList(),
        ],
      ),
    );
  }

  Widget _buildCenterListItem(Map<String, dynamic> center) {
    final bedAvailability = center['bedAvailability'] as int;
    final isFull = center['isFull'] as bool;
    final fundingStatus = center['fundingStatus'] as String;
    final mealsAvailable = center['mealsAvailable'] as int;

    // Determine status color
    Color statusColor = Colors.green;
    if (bedAvailability < 30 || mealsAvailable < 80) {
      statusColor = Colors.orange;
    }
    if (bedAvailability < 10 ||
        isFull ||
        fundingStatus == 'Urgent Funding Required') {
      statusColor = Colors.red;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        center['name'] as String,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _buildInfoChip(
            'Beds: ${bedAvailability}/${center['capacity']}',
            bedAvailability < 20 ? Colors.red : Colors.green,
          ),
          _buildInfoChip(
            'Meals: ${center['mealsAvailable']}%',
            mealsAvailable < 70 ? Colors.orange : Colors.green,
          ),
          if (center['tags'] != null)
            ...(center['tags'] as List<dynamic>).take(2).map((tag) =>
                _buildInfoChip(tag as String, _getTagColor(tag as String))),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          // TODO: Navigate to edit screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Edit functionality coming soon'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    if (tag.contains('Full') || tag.contains('Less Beds')) {
      return Colors.red;
    } else if (tag.contains('Funding Required')) {
      return Colors.orange;
    } else if (tag.contains('Food Shortage')) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}
