import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting users: $e');
      throw Exception('Failed to get users: $e');
    }
  }

  // Stream all users for real-time updates
  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Lock/Unlock user account
  Future<void> toggleUserLock(String userId, bool isLocked) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isLocked': isLocked,
        'lockedAt': isLocked ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ User ${isLocked ? "locked" : "unlocked"}: $userId');
    } catch (e) {
      print('❌ Error toggling user lock: $e');
      throw Exception('Failed to ${isLocked ? "lock" : "unlock"} user: $e');
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      // Mark as deleted instead of actually deleting
      await _firestore.collection('users').doc(userId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ User marked as deleted: $userId');
    } catch (e) {
      print('❌ Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  // Permanently delete user (admin only)
  Future<void> permanentlyDeleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // Note: Cannot delete Firebase Auth user from client side
      // This requires Firebase Admin SDK on server side
      
      print('✅ User permanently deleted: $userId');
    } catch (e) {
      print('❌ Error permanently deleting user: $e');
      throw Exception('Failed to permanently delete user: $e');
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        data?['uid'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ User role updated: $userId -> $role');
    } catch (e) {
      print('❌ Error updating user role: $e');
      throw Exception('Failed to update user role: $e');
    }
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error searching users: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final allUsers = await _firestore.collection('users').get();
      
      int totalUsers = allUsers.docs.length;
      int activeUsers = 0;
      int lockedUsers = 0;
      int deletedUsers = 0;

      for (var doc in allUsers.docs) {
        final data = doc.data();
        if (data['isDeleted'] == true) {
          deletedUsers++;
        } else if (data['isLocked'] == true) {
          lockedUsers++;
        } else {
          activeUsers++;
        }
      }

      return {
        'total': totalUsers,
        'active': activeUsers,
        'locked': lockedUsers,
        'deleted': deletedUsers,
      };
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      return {
        'total': 0,
        'active': 0,
        'locked': 0,
        'deleted': 0,
      };
    }
  }
}
