import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disciplined_coach/models/drug.dart';
import 'package:disciplined_coach/services/alarm_service.dart';
import 'package:disciplined_coach/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddDrugScreen extends StatefulWidget {
  final Drug? drug;

  const AddDrugScreen({super.key, this.drug});

  @override
  State<AddDrugScreen> createState() => _AddDrugScreenState();
}

class _AddDrugScreenState extends State<AddDrugScreen> {
  final _formKey = GlobalKey<FormState>();
  final AlarmService _alarmService = AlarmService();
  bool _isLoading = false;

  // Form values
  String? _name;
  String? _dosage;
  String _frequencyType = 'Saatlik';
  int? _frequencyValue;
  DateTime? _startDate;
  int? _stockTotal;

  @override
  void initState() {
    super.initState();
    if (widget.drug != null) {
      _name = widget.drug!.name;
      _dosage = widget.drug!.dosage;
      _frequencyType = widget.drug!.frequencyType;
      _frequencyValue = widget.drug!.frequencyValue;
      _startDate = widget.drug!.startDate.toDate();
      _stockTotal = widget.drug!.stockTotal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drug == null ? 'Yeni İlaç Ekle' : 'İlacı Düzenle'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final formContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              initialValue: _name,
                decoration: const InputDecoration(labelText: 'İlaç Adı'),
                validator: (val) => val!.isEmpty ? 'İlaç adı boş olamaz.' : null,
                onSaved: (val) => _name = val,
              ),
              TextFormField(
                initialValue: _dosage,
                decoration: const InputDecoration(labelText: 'Dozaj (örn: 500mg)'),
                validator: (val) => val!.isEmpty ? 'Lütfen bir dozaj girin' : null,
                onSaved: (val) => _dosage = val,
              ),
              DropdownButtonFormField<String>(
                value: _frequencyType,
                decoration: const InputDecoration(labelText: 'Sıklık Tipi'),
                items: ['Saatlik', 'Günlük'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _frequencyType = val!),
              ),
              TextFormField(
                initialValue: _frequencyValue?.toString(),
                decoration: InputDecoration(labelText: 'Sıklık Değeri (örn: 8 saat, 1 gün)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Lütfen bir değer girin.';
                  }
                  if (int.tryParse(val) == 0) {
                    return 'Geçerli bir sıklık girin (sıfırdan büyük).';
                  }
                  return null;
                },
                onSaved: (val) => _frequencyValue = int.tryParse(val!),
              ),
              TextFormField(
                initialValue: _stockTotal?.toString(),
                decoration: const InputDecoration(labelText: 'Stok Adedi'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => val!.isEmpty ? 'Stok adedi girin.' : null,
                onSaved: (val) => _stockTotal = int.tryParse(val!),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(_startDate == null
                        ? 'Başlangıç Tarihi Seçilmedi'
                        : 'Başlangıç: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Tarih Seç'),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (!_formKey.currentState!.validate() || _startDate == null) {
                    if (_startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen bir başlangıç tarihi seçin.')),
                      );
                    }
                    return;
                  }

                  setState(() => _isLoading = true);
                  _formKey.currentState!.save();

                  try {
                    final dbService = DatabaseService(uid: user!.uid);
                    final drugData = {
                      'name': _name,
                      'dosage': _dosage,
                      'frequencyType': _frequencyType,
                      'frequencyValue': _frequencyValue,
                      'startDate': Timestamp.fromDate(_startDate!),
                      'stockTotal': _stockTotal,
                      'stockRemaining': _stockTotal,
                    };

                    if (widget.drug == null) {
                      DocumentReference docRef = await dbService.addDrug(drugData);
                      await _alarmService.setExactDrugAlarm(docRef.id, _startDate!);
                    } else {
                      await dbService.updateDrug(widget.drug!.id, drugData);
                      await _alarmService.setExactDrugAlarm(widget.drug!.id, _startDate!);
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('İlaç başarıyla kaydedildi.')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kayıt hatası: $e')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kaydet'),
              )
            ],
          ),
        ),
      ),
    );

    if (widget.drug == null) {
      // Only wrap in a Hero for the "add new drug" flow.
      return Hero(tag: 'add_drug_hero', child: formContent);
    } else {
      // Don't use Hero for the "edit existing drug" flow.
      return formContent;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }
}
