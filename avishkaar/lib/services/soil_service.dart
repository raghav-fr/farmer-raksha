import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSoilService {
  static Future<Map<String, dynamic>?> getSoilProfile(String uid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("soil_profile")
        .doc("latest")
        .get();

    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }

  static Future<void> updateSoilProfile(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("soil_profile")
        .doc("latest")
        .set(data);
  }
}
