import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/models/drug.dart';
import 'package:home_widget/home_widget.dart';

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

  // Update discipline score
  Future<void> updateDisciplineScore(int newScore) async {
    await userCollection.doc(uid).update({
      'disciplineScore': newScore,
    });
    await HomeWidget.saveWidgetData<int>('score', newScore);
    await HomeWidget.updateWidget(name: 'ScoreWidgetProvider', iOSName: 'ScoreWidget');
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

  // Log a skipped drug with an excuse
  Future<void> logSkippedDrug(String drugId, {required String excuse}) async {
    await drugHistoryCollection.add({
      'userId': uid,
      'drugId': drugId,
      'scheduledTime': Timestamp.now(), // Placeholder
      'actionTime': Timestamp.now(),
      'status': 'atlandı',
      'excuse': excuse,
    });
    // TODO: Implement discipline score reduction for skipping.
  }

  // Get tomorrow's summary
  Future<Map<String, dynamic>> getTomorrowsSummary() async {
    final now = DateTime.now();
    final tomorrowStart = Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1));
    final tomorrowEnd = Timestamp.fromDate(DateTime(now.year, now.month, now.day + 2));

    try {
      final snapshot = await drugCollection
          .where('nextAlarmTime', isGreaterThanOrEqualTo: tomorrowStart)
          .where('nextAlarmTime', isLessThan: tomorrowEnd)
          .orderBy('nextAlarmTime')
          .get();

      if (snapshot.docs.isEmpty) {
        return {'totalDrugs': 0, 'firstAlarmTime': null};
      }

      final totalDrugs = snapshot.docs.length;
      final firstAlarmTime = (snapshot.docs.first.data() as Map<String, dynamic>)['nextAlarmTime'] as Timestamp;

      return {
        'totalDrugs': totalDrugs,
        'firstAlarmTime': firstAlarmTime.toDate(),
      };
    } catch (e) {
      // This can happen if the field 'nextAlarmTime' doesn't exist yet.
      // We'll return a default state.
      print('Error getting tomorrow summary: $e');
      return {'totalDrugs': 0, 'firstAlarmTime': null};
    }
  }
}
