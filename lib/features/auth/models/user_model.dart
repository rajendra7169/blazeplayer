import 'package:equatable/equatable.dart';

/// User data model
class UserModel extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata.creationTime,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoURL,
    phoneNumber,
    createdAt,
    lastLoginAt,
  ];
}
