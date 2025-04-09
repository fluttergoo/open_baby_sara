class UserModel {
  final String userID;
  final String email;
  final String firstName;
  final DateTime createdAt;
   List<Caregivers>? caregivers;

  UserModel({
    required this.userID,
    required this.email,
    required this.firstName,
    DateTime? createdAt,
    this.caregivers,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'firstName': firstName,
      'createdAt': createdAt.toIso8601String(),
      'caregivers': caregivers ==null ? [] : caregivers?.map((e) => e.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      createdAt: map['createdAt']
          ? (map['createdAt']).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      caregivers: (map['caregivers'] as List<dynamic>? ?? []).map((e) {
        return Caregivers.fromMap(e as Map<String, dynamic>);
      }).toList(),
    );
  }
}

class Caregivers {
  final String caregiverID;
  final String email;
  final String firstName;
  final DateTime createdAt;

  Caregivers({
    required this.caregiverID,
    required this.email,
    required this.firstName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'caregiverID': caregiverID,
      'email': email,
      'firstName': firstName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Caregivers.fromMap(Map<String, dynamic> map) {
    return Caregivers(
      caregiverID: map['caregiverID'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      createdAt: map['createdAt']
          ? (map['createdAt']).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}