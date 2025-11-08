import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/services/alarm_service.dart';
import 'package:disciplined_coach/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlarmScreen extends StatefulWidget {
  final String drugId;

  const AlarmScreen({super.key, required this.drugId});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late Future<DocumentSnapshot> _drugFuture;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User?>(context, listen: false);
    _drugFuture = DatabaseService(uid: user!.uid).drugCollection.doc(widget.drugId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: _drugFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text('İlaç bulunamadı.'));
            }

            final drugData = snapshot.data!.data() as Map<String, dynamic>;
            final drugName = drugData['name'] ?? 'Bilinmeyen İlaç';
            final dosage = drugData['dosage'] ?? '';

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.alarm, size: 100, color: Colors.blue),
                const SizedBox(height: 30),
                const Text(
                  'İlaç Zamanı!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '$drugName - $dosage',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                _buildActionButtons(context, drugData),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> drugData) {
    final user = Provider.of<User?>(context, listen: false);
    final dbService = DatabaseService(uid: user!.uid);
    final alarmService = AlarmService();

    final frequencyType = drugData['frequencyType'] ?? 'Saatlik';
    final frequencyValue = drugData['frequencyValue'] ?? 8;
    final stockRemaining = drugData['stockRemaining'] ?? 0;

    DateTime calculateNextAlarmTime() {
      if (frequencyType == 'Saatlik') {
        return DateTime.now().add(Duration(hours: frequencyValue));
      } else {
        return DateTime.now().add(Duration(days: frequencyValue));
      }
    }

    final nextAlarmTime = calculateNextAlarmTime();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
            onPressed: () async {
              if (stockRemaining > 0) {
                await dbService.updateDrug(widget.drugId, {'stockRemaining': stockRemaining - 1});
                await dbService.addDrugHistory(widget.drugId, 'alındı');
                await alarmService.setExactDrugAlarm(widget.drugId, nextAlarmTime);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Aldım', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
            onPressed: () async {
              await dbService.addDrugHistory(widget.drugId, 'ertelendi_1');
              await alarmService.setExactDrugAlarm(widget.drugId, DateTime.now().add(const Duration(minutes: 15)));
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Ertele (15 dk)', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextButton(
            onPressed: () async {
              await dbService.addDrugHistory(widget.drugId, 'atlandı');
              await alarmService.setExactDrugAlarm(widget.drugId, nextAlarmTime);
              await dbService.updateDisciplineScore(-5);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Atladım', style: TextStyle(fontSize: 18, color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
