import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/models/drug.dart';
import 'package:disciplined_coach/screens/add_drug_screen.dart';
import 'package:disciplined_coach/services/auth_service.dart';
import 'package:disciplined_coach/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          final todayWaterIntake = userData?['todayWaterIntake'] ?? 0;
          final dailyWaterGoal = userData?['dailyWaterGoal'] ?? 3000;
          final waterProgress = (dailyWaterGoal > 0) ? todayWaterIntake / dailyWaterGoal : 0.0;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Disiplinli Koç'),
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
                  _buildWaterCockpitCard(context, todayWaterIntake, dailyWaterGoal, waterProgress, user.uid),
                  const SizedBox(height: 20),
                  _buildMedicationListCard(context, user.uid),
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
    Color getScoreColor(int score) {
      if (score >= 80) {
        return Theme.of(context).colorScheme.primary; // Cerrahi Yeşil
      } else if (score >= 50) {
        return Colors.amber;
      } else {
        return Theme.of(context).colorScheme.error; // Kanamalı Kırmızı
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Disiplin Puanı', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              score.toString(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: getScoreColor(score),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCockpitCard(BuildContext context, int current, int goal, double progress, String uid) {
    final dbService = DatabaseService(uid: uid);
    final TextEditingController manualInputController = TextEditingController();

    void showManualAddDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Manuel Su Girişi'),
            content: TextField(
              controller: manualInputController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "ml cinsinden girin"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () async {
                  final amount = int.tryParse(manualInputController.text);
                  if (amount != null && amount > 0) {
                    await dbService.updateTodayWaterIntake(current + amount);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Ekle'),
              ),
            ],
          );
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Su Kokpiti', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text('$current / $goal ml', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'RobotoMono')),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[800],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () async => await dbService.updateTodayWaterIntake(current + 200), child: const Text('+200ml')),
                ElevatedButton(onPressed: () async => await dbService.updateTodayWaterIntake(current + 500), child: const Text('+500ml')),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: showManualAddDialog,
                  tooltip: 'Manuel Ekle',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationListCard(BuildContext context, String uid) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Bugünün İlaçları', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            StreamBuilder<List<Drug>>(
              stream: DatabaseService(uid: uid).drugs,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Henüz ilaç eklenmedi.');
                }
                final drugs = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: drugs.length,
                  itemBuilder: (context, index) {
                    final drug = drugs[index];
                    return Dismissible(
                      key: Key(drug.id),
                      onDismissed: (direction) async {
                        await DatabaseService(uid: uid).deleteDrug(drug.id);
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text(drug.name),
                        subtitle: Text(drug.dosage),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddDrugScreen(drug: drug),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
