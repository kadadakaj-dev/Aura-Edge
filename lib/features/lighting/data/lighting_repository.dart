import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/lighting_settings.dart';

class LightingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSettings(LightingSettings settings) async {
    final user = _auth.currentUser;
    if (user == null) return; // Ignore if not logged in

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('current')
        .set(settings.toMap(), SetOptions(merge: true));
  }

  Stream<LightingSettings?> watchSettings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return LightingSettings.fromMap(snapshot.data()!);
      }
      return null;
    });
  }
}
