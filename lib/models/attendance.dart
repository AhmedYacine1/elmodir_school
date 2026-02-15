import 'package:isar/isar.dart';

part 'attendance.g.dart';

@collection
class Attendance {
  Id? id;
  
  int studentId;
  DateTime date;
  String status; // present, absent, justified
  
  Attendance({
    this.id,
    required this.studentId,
    required this.date,
    required this.status,
  });
}