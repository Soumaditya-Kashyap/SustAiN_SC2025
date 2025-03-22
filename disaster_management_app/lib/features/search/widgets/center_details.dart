import 'package:flutter/material.dart';
import 'package:disaster_management_app/core/theme/app_colors.dart';
import 'package:disaster_management_app/features/search/widgets/donation_form.dart';

class CenterDetailsWidget extends StatelessWidget {
  final String city;
  final Map<String, dynamic> centerData;

  const CenterDetailsWidget({
    Key? key,
    required this.city,
    required this.centerData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final centerName = centerData['name'] as String;
    final capacity = centerData['capacity'] as int;
    final occupancy = centerData['occupancy'] as int;
    final isOperational = centerData['isOperational'] as bool;
    final needsFunding = centerData['needsFunding'] as bool;
    final address = centerData['address'] as String;
    final contact = centerData['contact'] as String;

    final availableSpace = capacity - occupancy;
    final occupancyPercentage = (occupancy / capacity) * 100;

    Color statusColor;
    String statusText;

    if (!isOperational) {
      statusColor = Colors.grey;
      statusText = 'Not Operational';
    } else if (availableSpace <= 0) {
      statusColor = Colors.red;
      statusText = 'Full';
    } else if (occupancyPercentage >= 80) {
      statusColor = Colors.orange;
      statusText = 'Limited Space';
    } else {
      statusColor = Colors.green;
      statusText = 'Available';
    }

    return Scaffold(
      body: Hero(
        tag: 'center-$centerName',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor.withOpacity(0.8),
                AppColors.backgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, centerName, statusColor, statusText),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationInfo(address),
                        const SizedBox(height: 24),
                        _buildCapacityInfo(capacity, occupancy, availableSpace,
                            occupancyPercentage),
                        const SizedBox(height: 24),
                        _buildContactInfo(contact),
                        const SizedBox(height: 24),
                        if (needsFunding) _buildFundingInfo(),
                        const SizedBox(height: 32),
                        _buildActionButtons(context, centerName),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String centerName,
      Color statusColor, String statusText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  centerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_city,
                size: 16,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                city,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String address) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade300,
              ),
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityInfo(int capacity, int occupancy, int availableSpace,
      double occupancyPercentage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Capacity Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCapacityItem(
                  'Total Capacity',
                  '$capacity',
                  Icons.people_alt,
                  Colors.blue,
                ),
                _buildCapacityItem(
                  'Current Occupancy',
                  '$occupancy',
                  Icons.person,
                  Colors.purple,
                ),
                _buildCapacityItem(
                  'Available Beds',
                  '$availableSpace',
                  Icons.hotel,
                  availableSpace > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Occupancy Level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: occupancy / capacity,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                color: occupancyPercentage >= 90
                    ? Colors.red
                    : occupancyPercentage >= 70
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${occupancyPercentage.toStringAsFixed(1)}% occupied',
              style: TextStyle(
                color: occupancyPercentage >= 90
                    ? Colors.red
                    : occupancyPercentage >= 70
                        ? Colors.orange
                        : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String contact) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.contact_phone,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Text(
                  contact,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Funding Needed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This center is in need of financial support to continue operations and provide essential services to disaster victims.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String centerName) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Handle contact action
            },
            icon: const Icon(Icons.phone),
            label: const Text('Contact Center'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DonationForm(
                  centerName: centerName,
                  city: city,
                ),
              );
            },
            icon: const Icon(Icons.volunteer_activism),
            label: const Text('Donate'),
          ),
        ),
      ],
    );
  }
}
