class EmergencyRequest {
  final String id;
  final String userId;
  final String userName;
  final String phoneNumber;
  final String location;
  final String description;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, double> coordinates;
  final int age;
  final String gender;
  final String? adminResponse;

  EmergencyRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.location,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.coordinates,
    required this.age,
    required this.gender,
    this.adminResponse,
  });

  factory EmergencyRequest.fromMap(Map<String, dynamic> map, String id) {
    // Handle coordinates with a safer approach
    Map<String, double> coordinatesMap = {};
    if (map['coordinates'] != null) {
      try {
        final coords = map['coordinates'];
        if (coords is Map) {
          coords.forEach((key, value) {
            if (value is num) {
              coordinatesMap[key.toString()] = value.toDouble();
            }
          });
        }
      } catch (e) {
        print('Error parsing coordinates: $e');
      }
    }

    // Safely handle date conversion
    DateTime createdAtDate = DateTime.now();
    if (map['createdAt'] != null) {
      try {
        if (map['createdAt'] is DateTime) {
          createdAtDate = map['createdAt'];
        } else if (map['createdAt']
            .runtimeType
            .toString()
            .contains('Timestamp')) {
          // Handle Firestore Timestamp
          createdAtDate = map['createdAt'].toDate();
        }
      } catch (e) {
        print('Error parsing createdAt date: $e');
      }
    }

    DateTime? updatedAtDate;
    if (map['updatedAt'] != null) {
      try {
        if (map['updatedAt'] is DateTime) {
          updatedAtDate = map['updatedAt'];
        } else if (map['updatedAt']
            .runtimeType
            .toString()
            .contains('Timestamp')) {
          // Handle Firestore Timestamp
          updatedAtDate = map['updatedAt'].toDate();
        }
      } catch (e) {
        print('Error parsing updatedAt date: $e');
      }
    }

    return EmergencyRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
      coordinates: coordinatesMap,
      age: map['age'] is int ? map['age'] : 0,
      gender: map['gender'] ?? '',
      adminResponse: map['adminResponse'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'location': location,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'coordinates': coordinates,
      'age': age,
      'gender': gender,
      'adminResponse': adminResponse,
    };
  }

  EmergencyRequest copyWith({
    String? status,
    DateTime? updatedAt,
    String? adminResponse,
  }) {
    return EmergencyRequest(
      id: id,
      userId: userId,
      userName: userName,
      phoneNumber: phoneNumber,
      location: location,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coordinates: coordinates,
      age: age,
      gender: gender,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}
