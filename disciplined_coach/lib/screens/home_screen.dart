import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/services/auth_service.dart';
import 'package:disciplined_coach/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplined_coach/screens/add_drug_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Kullanıcı bulunamadı.')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final disciplineScore = userData?['disciplineScore'] ?? 100;
          final currentWater = userData?['currentWater'] ?? 0.0;
          final waterGoal = userData?['waterGoal'] ?? 2500.0;
          final waterProgress = (waterGoal > 0) ? currentWater / waterGoal : 0.0;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Disiplinli Koç'),
              backgroundColor: Colors.grey[850],
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await auth.signOut();
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildDisciplineScoreCard(context, disciplineScore),
                  const SizedBox(height: 20),
                  _buildWaterTrackerCard(context, currentWater, waterGoal, waterProgress, user.uid),
                  const SizedBox(height: 20),
                  _buildMedicationListCard(context),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: 'İlaç Ekle',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddDrugScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget _buildDisciplineScoreCard(BuildContext context, int score) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Disiplin Puanı', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(score.toString(), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTrackerCard(BuildContext context, double current, double goal, double progress, String uid) {
    final dbService = DatabaseService(uid: uid);
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Günlük Su Takibi', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text('${current.toInt()} / ${goal.toInt()} ml'),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await dbService.updateCurrentWater(current + 200);
                  },
                  child: const Text('+200 ml'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await dbService.updateCurrentWater(current + 500);
                  },
                  child: const Text('+500 ml'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationListCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Bugünün İlaçları', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            const Text('Henüz ilaç eklenmedi.'),
          ],
        ),
      ),
    );
  }
}
