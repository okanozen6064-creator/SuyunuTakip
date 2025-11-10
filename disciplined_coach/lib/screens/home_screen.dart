import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/models/drug.dart';
import 'package:disciplined_coach/screens/add_drug_screen.dart';
import 'package:disciplined_coach/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/models/drug.dart';
import 'package:disciplined_coach/screens/add_drug_screen.dart';
import 'package:disciplined_coach/services/auth_service.dart';
import 'package:disciplined_coach/services/database_service.dart';
import 'package:disciplined_coach/widgets/discipline_score_widget.dart';
import 'package:disciplined_coach/widgets/main_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                MainBackground(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // TODO: Replace with new futuristic app bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                          onPressed: () async {
                            await auth.signOut();
                          },
                        )
                      ],
                    ),
                    DisciplineScoreWidget(score: disciplineScore),
                    if (disciplineScore < 50) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'RobotoMono',
                            color: Colors.redAccent,
                            shadows: [
                              Shadow(
                                blurRadius: 7.0,
                                color: Colors.redAccent,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              FlickerAnimatedText('UYARI: DİSİPLİN KIRILGANLIĞI TESPİT EDİLDİ'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildWaterCockpitCard(context, todayWaterIntake, dailyWaterGoal, waterProgress, user.uid),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 40,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'RobotoMono',
                          color: Colors.white70,
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          pause: const Duration(milliseconds: 2000),
                          animatedTexts: [
                            TyperAnimatedText('Acı geçicidir. Disiplin sonsuza dek kalır.'),
                            TyperAnimatedText('Bugünün disiplini, yarının zaferidir.'),
                            TyperAnimatedText('Zayıflık bir seçimdir. Başka bir şey seç.'),
                            TyperAnimatedText('Sorumluluktan kaçma. Sağlığından kaçamazsın.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMedicationListCard(context, user.uid),
                  ],
                    ),
                  ),
                ),
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
                  ],
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.05,
                ),
              ],
            ),
            floatingActionButton: Hero(
              tag: 'add_drug_hero',
              child: FloatingActionButton(
                tooltip: 'İlaç Ekle',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddDrugScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          );
        } else {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text('Su Kokpiti', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: 120,
            child: LiquidCircularProgressIndicator(
              value: progress,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade200),
              backgroundColor: Colors.transparent,
              borderColor: Colors.blue.shade800,
              borderWidth: 2.0,
              direction: Axis.vertical,
              center: Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'RobotoMono', color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('$current / $goal ml', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'RobotoMono', color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: () async => await dbService.updateTodayWaterIntake(current + 200), child: const Text('+200ml')),
              OutlinedButton(onPressed: () async => await dbService.updateTodayWaterIntake(current + 500), child: const Text('+500ml')),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: showManualAddDialog,
                tooltip: 'Manuel Ekle',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationListCard(BuildContext context, String uid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text('İlaç Görevleri', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: 10),
          StreamBuilder<List<Drug>>(
            stream: DatabaseService(uid: uid).drugs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Tüm görevler tamamlandı. Disiplin kazandı.', style: TextStyle(color: Colors.white70));
              }
              final drugs = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drugs.length,
                itemBuilder: (context, index) {
                  final drug = drugs[index];
                  // TODO: Implement particle effect on "Aldım" press
                  return Dismissible(
                    key: Key(drug.id),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) async {
                      await DatabaseService(uid: uid).deleteDrug(drug.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${drug.name} silindi.')),
                      );
                    },
                    background: Container(
                      color: Colors.red.withOpacity(0.3),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDrugScreen(drug: drug),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(drug.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(drug.dosage, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              _confettiController.play();
                              // We wait a bit for the animation to be seen before deleting
                              await Future.delayed(const Duration(milliseconds: 500));
                              await DatabaseService(uid: uid).deleteDrug(drug.id);
                            },
                            child: const Text('Aldım'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
