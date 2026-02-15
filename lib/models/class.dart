import 'package:isar/isar.dart';

part 'class.g.dart';

@collection
class ClassModel {
  Id? id;
  
  @Index(unique: false)
  String name;
  
  int? teacherId;
  int capacity;
  String shift; // morning, evening
  
  ClassModel({
    this.id,
    required this.name,
    this.teacherId,
    required this.capacity,
    required this.shift,
  });
}