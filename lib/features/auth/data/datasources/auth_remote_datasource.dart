import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  });

  Future<void> logout();

  Future<void> forgotPassword({
    required String email,
  });

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> sendEmailVerification();

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Đăng nhập thất bại');
      }

      // Get user data from Firestore
      final userDoc = await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw const AuthException('Không tìm thấy thông tin người dùng');
      }

      final userData = userDoc.data()!;
      
      // Check if user is blocked
      final isBlocked = userData['isBlocked'] as bool?;
      if (isBlocked == true) {
        await firebaseAuth.signOut();
        throw const AuthException('Tài khoản của bạn đã bị khóa');
      }

      return UserModel.fromJson({
        'id': credential.user!.uid,
        ...userData,
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Đăng ký thất bại');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final userData = {
        'email': email,
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'photoURL': null,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'addresses': <String>[],
        'isEmailVerified': credential.user!.emailVerified,
        'isBlocked': false,
      };

      await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      return UserModel.fromJson({
        'id': credential.user!.uid,
        ...userData,
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromJson({
        'id': user.uid,
        ...userDoc.data()!,
      });
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (displayName != null) {
        updateData['displayName'] = displayName;
        await firebaseAuth.currentUser?.updateDisplayName(displayName);
      }

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
        await firebaseAuth.currentUser?.updatePhotoURL(photoURL);
      }

      await firestore
          .collection('users')
          .doc(userId)
          .update(updateData);

      final userDoc = await firestore
          .collection('users')
          .doc(userId)
          .get();

      return UserModel.fromJson({
        'id': userId,
        ...userDoc.data()!,
      });
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('Người dùng chưa đăng nhập');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('Người dùng chưa đăng nhập');
      }

      await user.sendEmailVerification();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      try {
        final userDoc = await firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) return null;

        return UserModel.fromJson({
          'id': user.uid,
          ...userDoc.data()!,
        });
      } catch (e) {
        return null;
      }
    });
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản của bạn đã bị khóa';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 'operation-not-allowed':
        return 'Thao tác không được phép';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại';
    }
  }
}