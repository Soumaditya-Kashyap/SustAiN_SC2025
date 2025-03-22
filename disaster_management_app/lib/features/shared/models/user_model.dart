import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final int age;
  final String gender;
  final List<String> selectedLocations;
  final String? state;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.age,
    required this.gender,
    required this.selectedLocations,
    this.state,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'age': age,
      'gender': gender,
      'selectedLocations': selectedLocations,
      'state': state,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      age: map['age'] ?? 18,
      gender: map['gender'] ?? 'Male',
      selectedLocations: List<String>.from(map['selectedLocations'] ?? []),
      state: map['state'],
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    int? age,
    String? gender,
    List<String>? selectedLocations,
    String? state,
    String? role,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      state: state ?? this.state,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
