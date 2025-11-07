import 'package:cloud_firestore/cloud_firestore.dart';

class Drug {
  final String id;
  final String name;
  final String dosage;
  final String frequencyType;
  final int frequencyValue;
  final Timestamp startDate;
  final int stockTotal;
  final int stockRemaining;

  Drug({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequencyType,
    required this.frequencyValue,
    required this.startDate,
    required this.stockTotal,
    required this.stockRemaining,
  });
}
