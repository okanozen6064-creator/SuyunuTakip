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
    int? dailyWaterGoal,
    int? todayWaterIntake,
  }) async {
    return await userCollection.doc(uid).set({
      'disciplineScore': disciplineScore ?? 100,
      'dailyWaterGoal': dailyWaterGoal ?? 3000,
      'todayWaterIntake': todayWaterIntake ?? 0,
      'lastWaterResetDate': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // Get user data stream
  Stream<DocumentSnapshot> get userData {
    return userCollection.doc(uid).snapshots();
  }

  // Update discipline score by an amount (e.g., -5 for penalty)
  Future<void> updateDisciplineScore(int amount) async {
    return await userCollection.doc(uid).update({
      'disciplineScore': FieldValue.increment(amount),
    });
  }

  // Update today's water intake
  Future<void> updateTodayWaterIntake(int newWaterAmount) async {
    return await userCollection.doc(uid).update({
      'todayWaterIntake': newWaterAmount,
    });
  }

  // Add a new drug
  Future<DocumentReference> addDrug(Map<String, dynamic> drugData) async {
    return await drugCollection.add(drugData);
  }

  // Update an existing drug
  Future<void> updateDrug(String drugId, Map<String, dynamic> drugData) async {
    return await drugCollection.doc(drugId).update(drugData);
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

  // Decrement stock for a drug
  Future<void> decrementStock(String drugId) async {
    return await drugCollection.doc(drugId).update({
      'stockRemaining': FieldValue.increment(-1),
    });
  }

  // Log a drug action to history
  Future<void> logDrugAction(String drugId, String status) async {
    await drugHistoryCollection.add({
      'userId': uid,
      'drugId': drugId,
      'scheduledTime': Timestamp.now(), // Placeholder, should be the actual alarm time
      'actionTime': Timestamp.now(),
      'status': status,
    });
  }
}
