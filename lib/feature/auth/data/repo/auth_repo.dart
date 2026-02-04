import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';

abstract class AuthRepo {
  Future<Either<String, String>> signUp({
    required UserModel userModel,
    required String password,
  });

  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<String, void>> logout();
  Future<Either<String, UserModel>> getCurrentUser();
  Future<Either<String, void>> updateUserLocation(String uid, GeoPoint location);
  Future<Either<String, String>> generateInviteCode(String studentUid);
  Future<Either<String, void>> linkParentToChild({required String parentUid, required String inviteCode});
  Future<Either<String, List<UserModel>>> getParentChildren(String parentUid);
  Stream<GeoPoint> getChildLocationStream(String childUid);
}