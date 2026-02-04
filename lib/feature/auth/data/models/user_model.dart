import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String username;
  final String email;
  final String userType;
  final String inviteCode;
  final String? parentUid; // *** NEW: أضفنا حقل parentUid، يمكن أن يكون null

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.userType,
    this.inviteCode = '',
    this.parentUid, // *** NEW
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? 'بدون اسم',
      email: data['email'] ?? '',
      userType: data['userType'] ?? 'طالب',
      inviteCode: data['inviteCode'] ?? '',
      parentUid: data['parentUid'], // *** NEW: اقرأ الحقل من Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'userType': userType,
      'inviteCode': inviteCode,
      'parentUid': parentUid, // *** NEW: أضف الحقل عند الحفظ
    };
  }

  UserModel copyWith({
    String? username,
    String? userType,
    String? inviteCode,
    String? parentUid, // *** NEW: أضفه لـ copyWith
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      email: email,
      userType: userType ?? this.userType,
      inviteCode: inviteCode ?? this.inviteCode,
      parentUid: parentUid ?? this.parentUid, // *** NEW
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, username: $username, userType: $userType, inviteCode: $inviteCode, parentUid: $parentUid)'; // *** NEW

  @override
  List<Object?> get props => [uid, username, email, userType, inviteCode, parentUid]; // *** NEW: أضف parentUid
}