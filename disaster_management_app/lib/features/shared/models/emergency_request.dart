import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRequest {
  final String id;
  final String userId;
  final String userName;
  final String phoneNumber;
  final String location;
  final String description;
  final String status;
  final DateTime createdAt;
  final Map<String, double> coordinates;
  final int age;
  final String gender;

  EmergencyRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.location,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.coordinates,
    required this.age,
    required this.gender,
  });

  factory EmergencyRequest.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      coordinates: Map<String, double>.from(
          map['coordinates'] ?? {'lat': 0.0, 'lon': 0.0}),
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
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
      'createdAt': Timestamp.fromDate(createdAt),
      'coordinates': coordinates,
      'age': age,
      'gender': gender,
    };
  }

  EmergencyRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? phoneNumber,
    String? location,
    String? description,
    String? status,
    DateTime? createdAt,
    Map<String, double>? coordinates,
    int? age,
    String? gender,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      coordinates: coordinates ?? this.coordinates,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }
}
