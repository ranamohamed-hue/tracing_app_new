import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String username;
  final String email;
  final String userType;
  final String inviteCode;
  final String? parentUid; 

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.userType,
    this.inviteCode = '',
    this.parentUid, 
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? 'بدون اسم',
      email: data['email'] ?? '',
      userType: data['userType'] ?? 'طالب',
      inviteCode: data['inviteCode'] ?? '',
      parentUid: data['parentUid'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'userType': userType,
      'inviteCode': inviteCode,
      'parentUid': parentUid, 
    };
  }

  UserModel copyWith({
    String? username,
    String? userType,
    String? inviteCode,
    String? parentUid, 
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      email: email,
      userType: userType ?? this.userType,
      inviteCode: inviteCode ?? this.inviteCode,
      parentUid: parentUid ?? this.parentUid, 
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, username: $username, userType: $userType, inviteCode: $inviteCode, parentUid: $parentUid)'; 

  @override
  List<Object?> get props => [uid, username, email, userType, inviteCode, parentUid]; 
}