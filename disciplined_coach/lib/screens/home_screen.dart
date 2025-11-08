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
    Color cardColor;
    if (score >= 80) {
      cardColor = Colors.green.shade100;
    } else if (score >= 50) {
      cardColor = Colors.orange.shade100;
    } else {
      cardColor = Colors.red.shade100;
    }

    return Card(
      elevation: 4.0,
      color: cardColor,
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

  Widget _buildMedicationListCard(BuildContext context, String uid) {
    return Card(
      elevation: 4.0,
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
