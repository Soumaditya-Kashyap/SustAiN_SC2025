import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'package:disaster_management_app/core/theme/app_colors.dart';
import 'package:disaster_management_app/features/search/widgets/center_details.dart';
import 'package:disaster_management_app/features/search/widgets/donation_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';
  List<String> _filteredCities = [];
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    // Initialize with all cities that have rescue centers
    _filteredCities = AppConstants.rescueCentersByCity.keys.toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCities = AppConstants.rescueCentersByCity.keys.toList();
      } else {
        _filteredCities = AppConstants.rescueCentersByCity.keys
            .where((city) => city.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  void _showRescueCenterDetails(
      BuildContext context, String city, Map<String, dynamic> centerData) {
    showDialog(
      context: context,
      builder: (context) => RescueCenterDetailDialog(
        city: city,
        centerData: centerData,
      ),
    );
  }

  Color _getStatusColor(Map<String, dynamic> centerData) {
    if (centerData['isFull'] == true) {
      return Colors.red.shade100;
    } else if (centerData['bedAvailability'] < 20) {
      return Colors.orange.shade100;
    } else {
      return Colors.green.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Search Rescue Centers',
        showBackButton: true,
      ),
      body: Container(
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by city name...',
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: _filterCities,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No rescue centers found',
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
                          itemCount: _filteredCities.length,
                          itemBuilder: (context, cityIndex) {
                            final city = _filteredCities[cityIndex];
                            final centersInCity =
                                AppConstants.rescueCentersByCity[city] ?? [];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // City header with expand/collapse
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (_expandedIndex == cityIndex) {
                                          _expandedIndex = null;
                                        } else {
                                          _expandedIndex = cityIndex;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade700,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_city,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                city,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${centersInCity.length} centers',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            _expandedIndex == cityIndex
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expanded content with rescue centers list
                                  if (_expandedIndex == cityIndex)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: centersInCity.length,
                                      itemBuilder: (context, centerIndex) {
                                        final centerData =
                                            centersInCity[centerIndex];
                                        return GestureDetector(
                                          onTap: () => _showRescueCenterDetails(
                                              context, city, centerData),
                                          child: Container(
                                            margin: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  _getStatusColor(centerData),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 24,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Icon(
                                                          Icons.local_hospital,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: 28,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              centerData[
                                                                  'name'],
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              centerData[
                                                                  'address'],
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Wrap(
                                                              spacing: 6,
                                                              runSpacing: 6,
                                                              children: [
                                                                ...List
                                                                    .generate(
                                                                  centerData['tags']
                                                                          ?.length ??
                                                                      0,
                                                                  (index) =>
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            2),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: _getTagColor(
                                                                          centerData['tags']
                                                                              [
                                                                              index]),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                    ),
                                                                    child: Text(
                                                                      centerData[
                                                                              'tags']
                                                                          [
                                                                          index],
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: _getTagTextColor(centerData['tags']
                                                                            [
                                                                            index]),
                                                                      ),
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
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _buildInfoColumn(
                                                        'Beds',
                                                        '${centerData['bedAvailability']}/${centerData['capacity']}',
                                                        centerData['bedAvailability'] <
                                                                20
                                                            ? Colors.red
                                                            : Colors.green,
                                                      ),
                                                      _buildInfoColumn(
                                                        'Meals',
                                                        '${centerData['mealsAvailable']}%',
                                                        centerData['mealsAvailable'] <
                                                                70
                                                            ? Colors.orange
                                                            : Colors.green,
                                                      ),
                                                      _buildInfoColumn(
                                                        'Status',
                                                        centerData['isFull']
                                                            ? 'Full'
                                                            : 'Available',
                                                        centerData['isFull']
                                                            ? Colors.red
                                                            : Colors.green,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Center(
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          _showRescueCenterDetails(
                                                              context,
                                                              city,
                                                              centerData),
                                                      child: const Text(
                                                          'View Details'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getTagColor(String tag) {
    if (tag.contains('Full') || tag.contains('Less Beds')) {
      return Colors.red.shade100;
    } else if (tag.contains('Funding Required')) {
      return Colors.orange.shade100;
    } else if (tag.contains('Food Shortage')) {
      return Colors.amber.shade100;
    } else {
      return Colors.green.shade100;
    }
  }

  Color _getTagTextColor(String tag) {
    if (tag.contains('Full') || tag.contains('Less Beds')) {
      return Colors.red.shade900;
    } else if (tag.contains('Funding Required')) {
      return Colors.orange.shade900;
    } else if (tag.contains('Food Shortage')) {
      return Colors.amber.shade900;
    } else {
      return Colors.green.shade900;
    }
  }
}

class RescueCenterDetailDialog extends StatefulWidget {
  final String city;
  final Map<String, dynamic> centerData;

  const RescueCenterDetailDialog({
    super.key,
    required this.city,
    required this.centerData,
  });

  @override
  State<RescueCenterDetailDialog> createState() =>
      _RescueCenterDetailDialogState();
}

class _RescueCenterDetailDialogState extends State<RescueCenterDetailDialog> {
  final TextEditingController _donationAmountController =
      TextEditingController();
  bool _showDonationForm = false;
  bool _donationSuccess = false;

  @override
  void dispose() {
    _donationAmountController.dispose();
    super.dispose();
  }

  void _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  void _processDonation() {
    if (_donationAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a donation amount')),
      );
      return;
    }

    // Simulate donation processing
    setState(() {
      _donationSuccess = true;
    });

    // Show success message and close after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.centerData;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final data = widget.centerData;

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: _donationSuccess
          ? _buildDonationSuccess()
          : _showDonationForm
              ? _buildDonationForm()
              : _buildCenterDetails(data),
    );
  }

  Widget _buildDonationSuccess() {
    final data = widget.centerData;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'Donation Successful!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Thank you for your generous donation of ₹${_donationAmountController.text} to ${data['name']}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            'You are making a difference!',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _showDonationForm = false;
                  });
                },
              ),
              const Text(
                'Make a Donation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Your donation will help provide essential services to those in need.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _donationAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Donation Amount (₹)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.currency_rupee),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Donate Now',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterDetails(Map<String, dynamic> data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.local_hospital,
                  color: Colors.blue.shade700,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.city,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Body content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.location_on, color: Colors.grey.shade700),
                  title: const Text('Address'),
                  subtitle: Text(data['address']),
                ),

                const Divider(),

                // Stats in cards
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Capacity',
                          '${data['capacity']}',
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Available',
                          '${data['bedAvailability']}',
                          Icons.hotel,
                          data['bedAvailability'] < 20
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Meals',
                          '${data['mealsAvailable']}%',
                          Icons.restaurant,
                          data['mealsAvailable'] < 70
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Description
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(data['description']),

                const SizedBox(height: 16),

                // Facilities
                const Text(
                  'Facilities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    data['facilities'].length,
                    (index) => Chip(
                      backgroundColor: Colors.blue.shade50,
                      label: Text(
                        data['facilities'][index],
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Status
                Card(
                  color: data['fundingStatus'] == 'Urgent Funding Required'
                      ? Colors.red.shade50
                      : data['fundingStatus'] == 'Funding Required'
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color:
                              data['fundingStatus'] == 'Urgent Funding Required'
                                  ? Colors.red
                                  : data['fundingStatus'] == 'Funding Required'
                                      ? Colors.orange
                                      : Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            data['fundingStatus'],
                            style: TextStyle(
                              color: data['fundingStatus'] ==
                                      'Urgent Funding Required'
                                  ? Colors.red.shade800
                                  : data['fundingStatus'] == 'Funding Required'
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makeCall(data['phone']),
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text(
                          'Contact',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showDonationForm = true;
                          });
                        },
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        label: const Text(
                          'Donate',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
