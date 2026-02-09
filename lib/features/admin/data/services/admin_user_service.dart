import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Get all users
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Convert Timestamp fields to DateTime or String
        // Only convert if field exists and is Timestamp
        if (data.containsKey('createdAt') && data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }
        if (data.containsKey('updatedAt') && data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
        }
        if (data.containsKey('lastLoginAt') && data['lastLoginAt'] is Timestamp) {
          data['lastLoginAt'] = (data['lastLoginAt'] as Timestamp).toDate();
        }
        
        return data;
      }).toList();
      
      // Sort by createdAt if available
      docs.sort((a, b) {
        final aDate = a['createdAt'];
        final bDate = b['createdAt'];
        if (aDate is DateTime && bDate is DateTime) {
          return bDate.compareTo(aDate);
        }
        return 0;
      });
      
      return docs;
    });
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
      }
      return data;
    }
    return null;
  }

  // Update user status (active/blocked)
  Future<void> updateUserStatus(String userId, bool isActive) async {
    await _firestore.collection(_collection).doc(userId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle block/unblock user
  Future<void> toggleBlockUser(String userId, bool block) async {
    await _firestore.collection(_collection).doc(userId).update({
      'isBlocked': block,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    final snapshot = await _firestore.collection(_collection).get();
    
    return {
      'total': snapshot.docs.length,
      'active': snapshot.docs.where((doc) => doc.data()['isActive'] == true).length,
      'blocked': snapshot.docs.where((doc) => doc.data()['isActive'] == false).length,
    };
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }
}
