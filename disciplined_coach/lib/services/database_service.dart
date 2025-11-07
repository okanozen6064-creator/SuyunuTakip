import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData({
    int? disciplineScore,
    double? waterGoal,
    double? currentWater,
  }) async {
    return await userCollection.doc(uid).set({
      'disciplineScore': disciplineScore ?? 100,
      'waterGoal': waterGoal ?? 2500.0,
      'currentWater': currentWater ?? 0.0,
    }, SetOptions(merge: true));
  }

  // Get user data stream
  Stream<DocumentSnapshot> get userData {
    return userCollection.doc(uid).snapshots();
  }

  // Update current water
  Future<void> updateCurrentWater(double newWaterAmount) async {
    return await userCollection.doc(uid).update({
      'currentWater': newWaterAmount,
    });
  }
}
