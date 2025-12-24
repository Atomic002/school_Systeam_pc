// lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String? branchId;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? gender;
  final DateTime? birthDate;
  final String? phone;
  final String? phoneSecondary;
  final String? region;
  final String? district;
  final String? address;
  final String role;
  final String status;
  final String username;
  final String? passwordHash;
  final String? tempPassword;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.branchId,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.gender,
    this.birthDate,
    this.phone,
    this.phoneSecondary,
    this.region,
    this.district,
    this.address,
    required this.role,
    required this.status,
    required this.username,
    this.passwordHash,
    this.tempPassword,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      branchId: json['branch_id'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      phone: json['phone'] as String?,
      phoneSecondary: json['phone_secondary'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      username: json['username'] as String,
      passwordHash: json['password_hash'] as String?,
      tempPassword: json['temp_password'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'phone': phone,
      'phone_secondary': phoneSecondary,
      'region': region,
      'district': district,
      'address': address,
      'role': role,
      'status': status,
      'username': username,
      'password_hash': passwordHash,
      'temp_password': tempPassword,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName {
    if (middleName != null) {
      return '$firstName $lastName $middleName';
    }
    return '$firstName $lastName';
  }

  String get shortName {
    return '$lastName $firstName';
  }

  String get roleInUzbek {
    switch (role) {
      case 'owner':
        return 'Ega';
      case 'manager':
        return 'Maktab boshqaruvchisi';
      case 'director':
        return 'Direktor';
      case 'admin':
        return 'Administrator';
      case 'teacher':
        return 'O\'qituvchi';
      case 'staff':
        return 'Hodim';
      default:
        return role;
    }
  }

  bool get isActive => status == 'active';

  get branchName => null;

  bool hasRole(String roleToCheck) => role == roleToCheck;

  bool hasAnyRole(List<String> roles) => roles.contains(role);

  UserModel copyWith({
    String? id,
    String? branchId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? gender,
    DateTime? birthDate,
    String? phone,
    String? phoneSecondary,
    String? region,
    String? district,
    String? address,
    String? role,
    String? status,
    String? username,
    String? passwordHash,
    String? tempPassword,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      phoneSecondary: phoneSecondary ?? this.phoneSecondary,
      region: region ?? this.region,
      district: district ?? this.district,
      address: address ?? this.address,
      role: role ?? this.role,
      status: status ?? this.status,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      tempPassword: tempPassword ?? this.tempPassword,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
