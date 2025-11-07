import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/models/drug.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection references
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference drugHistoryCollection = FirebaseFirestore.instance.collection('drug_history');

  // Get user's drugs subcollection reference
  CollectionReference get drugCollection => userCollection.doc(uid).collection('drugs');

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

  // Add a new drug
  Future<DocumentReference> addDrug(Map<String, dynamic> drugData) async {
    return await drugCollection.add(drugData);
  }

  // Get drugs stream
  Stream<List<Drug>> get drugs {
    return drugCollection.snapshots().map(_drugListFromSnapshot);
  }

  // drug list from snapshot
  List<Drug> _drugListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Drug(
        id: doc.id,
        name: data['name'] ?? '',
        dosage: data['dosage'] ?? '',
        frequencyType: data['frequencyType'] ?? 'daily',
        frequencyValue: data['frequencyValue'] ?? 1,
        startDate: data['startDate'] ?? Timestamp.now(),
        stockTotal: data['stockTotal'] ?? 0,
        stockRemaining: data['stockRemaining'] ?? 0,
      );
    }).toList();
  }

  // Delete a drug
  Future<void> deleteDrug(String drugId) async {
    return await drugCollection.doc(drugId).delete();
  }

  // Add a drug history record
  Future<void> addDrugHistory(String drugId, String status) async {
    await drugHistoryCollection.add({
      'userId': uid,
      'drugId': drugId,
      'scheduledTime': Timestamp.now(), // Placeholder, will be passed from alarm
      'actionTime': Timestamp.now(),
      'status': status,
    });
  }
}
