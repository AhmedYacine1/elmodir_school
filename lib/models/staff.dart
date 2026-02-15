import 'package:isar/isar.dart';

part 'staff.g.dart';

@collection
class Staff {
  Id? id;
  
  @Index(unique: false)
  String fullName;
  
  @Index(unique: false)
  String role; // teacher, admin, assistant
  
  @Index(unique: true)
  String phone;
  
  double salary;
  bool isActive;
  
  Staff({
    this.id,
    required this.fullName,
    required this.role,
    required this.phone,
    required this.salary,
    this.isActive = true,
  });
}