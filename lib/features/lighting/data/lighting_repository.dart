import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/lighting_settings.dart';

abstract class LightingRepository {
  Future<void> saveSettings(LightingSettings settings);
  Stream<LightingSettings?> watchSettings();
  Future<LightingSettings> getSettings();
}

class FirebaseLightingRepository implements LightingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseLightingRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> saveSettings(LightingSettings settings) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('current')
        .set(settings.toMap(), SetOptions(merge: true));
  }

  @override
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

  @override
  Future<LightingSettings> getSettings() async {
    final user = _auth.currentUser;
    if (user == null) return const LightingSettings();

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('current')
          .get();

      if (doc.exists && doc.data() != null) {
        return LightingSettings.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
    return const LightingSettings();
  }
}
