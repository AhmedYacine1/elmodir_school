import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'student.g.dart';

@collection
class Student {
  Id? id;
  
  @Index(unique: false)
  String firstName;
  
  @Index(unique: false)
  String lastName;
  
  DateTime birthDate;
  String gender;
  String? address;
  int? parentId;
  int? classId;
  
  @Index(unique: true)
  String registrationNumber;
  
  bool isActive;
  DateTime createdAt;
  
  Student({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    this.address,
    this.parentId,
    this.classId,
    required this.registrationNumber,
    this.isActive = true,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}