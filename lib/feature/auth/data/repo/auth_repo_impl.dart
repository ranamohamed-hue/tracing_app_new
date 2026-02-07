import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepoImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseAuth = firebaseAuth,
       _firebaseFirestore = firebaseFirestore;

  // --- منطق المصادقة الأساسي (لم يتغير) ---
  @override
  Future<Either<String, String>> signUp({
    required UserModel userModel,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      final newUser = UserModel(
        uid: credential.user!.uid,
        username: userModel.username,
        email: userModel.email,
        userType: userModel.userType,
      );

      await _firebaseFirestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      await credential.user!.sendEmailVerification();

      return const Right(
        'تم إنشاء الحساب بنجاح! يرجى التحقق من بريدك الإلكتروني لتفعيل الحساب.',
      );
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      return Left('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        return const Left(
          'يرجى تفعيل بريدك الإلكتروني أولاً. تحقق من صندوق الوارد.',
        );
      }

      final userDoc = await _firebaseFirestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (!userDoc.exists) {
        return const Left('بيانات المستخدم غير موجودة.');
      }
      final user = UserModel.fromFirestore(userDoc);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      return Left('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

@override
  Future<Either<String, String>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(
        'تم إرسال رابط استعادة كلمة المرور بنجاح! يرجى التحقق من بريدك الإلكتروني.',
      );
    } on FirebaseAuthException catch (e) {
      // استخدمنا الدالة المساعدة اللي انتي عاملاها للمابينج
      return Left(_mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      return Left('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }


  @override
  Future<Either<String, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserModel>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Left('لا يوجد مستخدم مسجل دخوله حالياً.');
      }

      if (!firebaseUser.emailVerified) {
        return const Left('البريد الإلكتروني للمستخدم الحالي غير مُفعّل.');
      }

      final userDoc = await _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return const Left('بيانات المستخدم غير موجودة في قاعدة البيانات.');
      }

      final user = UserModel.fromFirestore(userDoc);
      return Right(user);
    } catch (e) {
      return Left('فشل جلب بيانات المستخدم: ${e.toString()}');
    }
  }

  // --- منطق التتبع والموقع (لم يتغير) ---
  @override
  Future<Either<String, void>> updateUserLocation(
    String uid,
    GeoPoint location,
  ) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('location')
          .doc('currentLocation')
          .set({
            'location': location,
            'timestamp': FieldValue.serverTimestamp(),
          });
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث الموقع: ${e.toString()}');
    }
  }

  // --- منطق ربط ولي الأمر بالطالب (تم تعديله) ---
  @override
  Future<Either<String, String>> generateInviteCode(String studentUid) async {
    try {
      // *** تحسين: للتأكد من أن الكود فريد (اختياري لكن مفيد) ***
      String code;
      bool codeExists;
      do {
        code = _generateRandomCode();
        final snapshot = await _firebaseFirestore
            .collection('users')
            .where('inviteCode', isEqualTo: code)
            .limit(1)
            .get();
        codeExists = snapshot.docs.isNotEmpty;
      } while (codeExists);

      await _firebaseFirestore
          .collection('users')
          .doc(studentUid)
          .update({'inviteCode': code});
      return Right(code);
    } catch (e) {
      return Left('فشل إنشاء كود الدعوة: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> linkParentToChild({
    required String parentUid,
    required String inviteCode,
  }) async {
    try {
      // *** تحسين: ابحث عن الطالب خارج المعاملة للحصول على مرجع المستند (DocumentReference) ***
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('inviteCode', isEqualTo: inviteCode)
          .where('parentUid', isNull: true) // *** مهم: تأكد من أن الطالب غير مربوط بعد ***
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Left('كود الدعوة غير صحيح أو تم استخدامه.');
      }

      final childDocSnapshot = querySnapshot.docs.first;
      final childUid = childDocSnapshot.id;
      final childData = childDocSnapshot.data() as Map<String, dynamic>;

      // أنشئ المراجع التي ستحتاجها داخل المعاملة
      final childDocRef = _firebaseFirestore.collection('users').doc(childUid);
      final parentChildrenRef = _firebaseFirestore.collection('users').doc(parentUid).collection('children').doc(childUid);

      // *** تحسين: قم بتشغيل المعاملة باستخدام المراجع لضمان التنفيذ الذري ***
      await _firebaseFirestore.runTransaction((transaction) async {
        // يمكنك إعادة جلب المستند داخل المعاملة للتأكد من أنه لم يتغير
        transaction.get(childDocRef);

        // 1. أضف الطالب إلى مجموعة الأبناء لدى ولي الأمر
        transaction.set(parentChildrenRef, {
          'childName': childData['username'],
          'addedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        // 2. *** مهم: حدث بيانات الطالب بإضافة parentUid وحذف الكود ***
        transaction.update(childDocRef, {
          'parentUid': parentUid,
          'inviteCode': FieldValue.delete(),
        });
      });

      return const Right(null);
    } catch (e) {
      return Left('فشل ربط الطالب: ${e.toString()}');
    }
  }

  // --- منطق جلب الأبناء (لم يتغير، لكنه يعمل بشكل صحيح مع التعديلات الجديدة) ---
  @override
  Future<Either<String, List<UserModel>>> getParentChildren(String parentUid) async {
    try {
      final childrenSnapshot = await _firebaseFirestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .get();

      if (childrenSnapshot.docs.isEmpty) {
        return const Right([]);
      }

      List<UserModel> children = [];
      for (var doc in childrenSnapshot.docs) {
        final childDoc = await _firebaseFirestore.collection('users').doc(doc.id).get();
        if (childDoc.exists) {
          children.add(UserModel.fromFirestore(childDoc));
        }
      }
      return Right(children);
    } catch (e) {
      return Left('فشل جلب الأبناء: ${e.toString()}');
    }
  }

 @override
Stream<GeoPoint> getChildLocationStream(String childUid) {
  return _firebaseFirestore
      .collection('users')
      .doc(childUid)
      .collection('location')
      .doc('currentLocation')
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          // تأكد من اسم الحقل داخل الفايربيز
          return snapshot.data()!['location'] as GeoPoint;
        }
        // إرجاع قيمة افتراضية لتجنب خطأ الـ Null check operator
        return const GeoPoint(0, 0); 
      });
}

  // --- دوال مساعدة (لم تتغير) ---
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  String _mapFirebaseErrorToMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل.';
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      default:
        return 'حدث خطأ: $code';
    }
  }
}