import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/driver_model.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<DriverModel>> getDrivers() async {
    final snap = await _firestore.collection('drivers').get();
    return snap.docs.map((doc) {
      return DriverModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  static Future<DriverModel?> getDriver(String id) async {
    final doc = await _firestore.collection('drivers').doc(id).get();
    if (!doc.exists) return null;
    return DriverModel.fromMap(doc.id, doc.data()!);
  }

  static Future<int> getParentCount(String driverId) async {
    final snap = await _firestore
        .collection('parents')
        .where('driverId', isEqualTo: driverId)
        .get();
    return snap.docs.length;
  }

  static Future<void> saveParent({
    required String parentId,
    required double lat,
    required double lng,
    required String driverId,
    required String fcmToken,
  }) async {
    await _firestore.collection('parents').doc(parentId).set({
      'homeLocation': {'lat': lat, 'lng': lng},
      'driverId': driverId,
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final snap = await _firestore.collection('announcements').get();
    final announcements = snap.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
    // Sadece 'all' veya 'drivers' hedefli duyuruları filtrele
    final filtered = announcements.where((a) {
      final target = a['target'] as String? ?? 'all';
      return target == 'all' || target == 'drivers';
    }).toList();
    filtered.sort((a, b) {
      final aDate = DateTime.parse(a['createdAt']);
      final bDate = DateTime.parse(b['createdAt']);
      return bDate.compareTo(aDate);
    });
    return filtered;
  }

  static Future<void> updateDriverLocation(String driverId, double lat, double lng) async {
    await _firestore
        .collection('drivers')
        .doc(driverId)
        .collection('location')
        .doc('current')
        .set({
      'lat': lat,
      'lng': lng,
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
