import 'package:flutter/material.dart';

class AddDrugScreen extends StatefulWidget {
  const AddDrugScreen({super.key});

  @override
  State<AddDrugScreen> createState() => _AddDrugScreenState();
}

class _AddDrugScreenState extends State<AddDrugScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form values will be added here later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlaç Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const Text('İlaç Detayları'),
            TextFormField(
              decoration: const InputDecoration(hintText: 'İlaç Adı'),
              validator: (val) => val!.isEmpty ? 'Lütfen bir isim girin' : null,
              // onChanged: (val) => setState(() => _name = val),
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Dozaj (örn: 500mg)'),
              validator: (val) => val!.isEmpty ? 'Lütfen bir dozaj girin' : null,
              // onChanged: (val) => setState(() => _dosage = val),
            ),
            // ... Other form fields will be added here
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // TODO: Save to Firestore and set alarm
                }
              },
              child: const Text('Kaydet'),
            )
          ],
        ),
      ),
    );
  }
}
