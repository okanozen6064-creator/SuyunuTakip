import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  final String? drugId; // Passed from native intent

  const AlarmScreen({super.key, this.drugId});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch drug name using drugId from Firestore

    return Scaffold(
      body: SafeArea(
        child: Column(
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
              'İlaç Adı: (Buraya ilaç adı gelecek)', // Placeholder
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                onPressed: () {
                  // TODO: Call addDrugHistory with 'alındı'
                  // TODO: Set next alarm
                  // TODO: Close the alarm screen/app
                },
                child: const Text('Aldım', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                onPressed: () {
                  // TODO: Call addDrugHistory with 'ertelendi_1'
                  // TODO: Set next alarm for 15 mins later
                  // TODO: Close the alarm screen/app
                },
                child: const Text('Ertele (15 dk)', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextButton(
                onPressed: () {
                  // TODO: Call addDrugHistory with 'atlandı'
                  // TODO: Set next alarm for the next scheduled time
                  // TODO: Close the alarm screen/app
                },
                child: const Text('Atladım', style: TextStyle(fontSize: 18, color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
