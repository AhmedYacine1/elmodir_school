import 'package:isar/isar.dart';

part 'parent.g.dart';

@collection
class Parent {
  Id? id;
  
  @Index(unique: false)
  String fullName;
  
  @Index(unique: true)
  String phone;
  
  String? job;
  String? address;
  String? notes;
  
  Parent({
    this.id,
    required this.fullName,
    required this.phone,
    this.job,
    this.address,
    this.notes,
  });
}